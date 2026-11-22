{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  upstream = inputs.t3code.packages.${pkgs.stdenv.hostPlatform.system}.t3code-nightly;

  rootBackground = "<style>html.dark body,body{background:transparent!important}html[data-theme-id]{background:var(--app-chrome-background)!important;--surface-grain:none!important}html[data-theme-id] main[data-slot=sidebar-inset],html[data-theme-id] [data-app-sidebar]{--background:transparent!important}</style>";

  # Chromium counts the Mod key as keyboard input, so every press would ring the focused workspace region.
  hideWorkspaceRing = "<style>[data-workspace-area]:focus-visible{outline:none!important}</style>";

  contents =
    pkgs.runCommand "${upstream.name}-transparent-extracted" { nativeBuildInputs = [ pkgs.asar ]; }
      ''
        cp -r ${upstream.contents} $out
        chmod -R u+w $out

        asar extract $out/resources/app.asar $out/resources/app
        rm -r $out/resources/app.asar $out/resources/app.asar.unpacked

        substituteInPlace $out/resources/app/apps/desktop/dist-electron/main.cjs \
          --replace-fail 'return shouldUseDarkColors ? "#000000" : "#ffffff";' 'return "#00000000";' \
          --replace-fail 'minHeight: MIN_MAIN_WINDOW_SIZE.height,' 'minHeight: MIN_MAIN_WINDOW_SIZE.height, transparent: true,'

        substituteInPlace $out/resources/app/apps/server/dist/client/index.html \
          --replace-fail '</head>' '${rootBackground}${hideWorkspaceRing}</head>'
      '';

  t3code = pkgs.appimageTools.wrapAppImage {
    inherit (upstream) pname version meta;
    src = contents;

    extraPkgs = pkgs: [ pkgs.libsecret ];

    extraInstallCommands = ''
      cp -r ${upstream}/share $out/
    '';
  };

  nrsSocket = "/run/t3-nrs.sock";

  # Builds the desktop system from ~/Dotfiles as nolight and switches to it as root.
  # The switch runs in its own transient unit so it survives the restart of any unit it touches.
  nrsSwitch = pkgs.writeShellApplication {
    name = "t3-nrs-switch";
    runtimeInputs = [
      config.nix.package
      pkgs.git
      pkgs.util-linux
      config.systemd.package
    ];
    text = ''
      exec 9>/run/t3-nrs.lock
      flock 9

      path=$(runuser -u nolight -- nix build --no-link --print-out-paths \
        /home/nolight/Dotfiles#nixosConfigurations.desktop.config.system.build.toplevel)

      if [[ ! $path =~ ^/nix/store/[a-z0-9]{32}-nixos-system-[^/]+$ ]]; then
        echo "t3-nrs: unexpected build result: $path" >&2
        exit 1
      fi

      nix-env --profile /nix/var/nix/profiles/system --set "$path"
      systemd-run --wait --pipe --collect --service-type=exec --unit=t3-nrs-switch-to-configuration \
        -- "$path/bin/switch-to-configuration" switch
    '';
  };

  # Serves one connection on the t3-nrs socket. It runs nrsSwitch only when the peer descends from
  # the T3 Code main process, and ends its output with a "t3-nrs-exit <code>" line.
  nrsGate = pkgs.writers.writePython3Bin "t3-nrs-gate" { flakeIgnore = [ "E501" ]; } ''
    import os
    import pwd
    import socket
    import struct
    import subprocess
    import sys

    T3CODE = os.stat("${contents}/t3code")


    def is_t3code_main(pid):
        st = os.stat(f"/proc/{pid}/exe")
        if (st.st_dev, st.st_ino) != (T3CODE.st_dev, T3CODE.st_ino):
            return False
        with open(f"/proc/{pid}/environ", "rb") as f:
            env = f.read().split(b"\0")
        return not any(e.startswith(b"ELECTRON_RUN_AS_NODE=") for e in env)


    def parent(pid):
        with open(f"/proc/{pid}/status") as f:
            for line in f:
                if line.startswith("PPid:"):
                    return int(line.split()[1])
        return 0


    def allowed(pid):
        try:
            while pid > 1:
                if is_t3code_main(pid):
                    return True
                pid = parent(pid)
        except OSError:
            pass
        return False


    conn = socket.socket(fileno=0)
    creds = conn.getsockopt(socket.SOL_SOCKET, socket.SO_PEERCRED, struct.calcsize("3i"))
    pid, uid, _ = struct.unpack("3i", creds)

    if pwd.getpwuid(uid).pw_name != "nolight" or not allowed(pid):
        print("t3-nrs: denied, the caller is not running under T3 Code", flush=True)
        code = 1
    else:
        code = subprocess.run(["${lib.getExe nrsSwitch}"]).returncode

    print(f"\nt3-nrs-exit {code}", flush=True)
    sys.exit(code)
  '';

  # Client for the T3 Code agent. It streams the rebuild log and exits with the rebuild's status.
  nrsClient = pkgs.writers.writePython3Bin "t3-nrs" { } ''
    import socket
    import subprocess
    import sys

    conn = socket.socket(socket.AF_UNIX)
    conn.connect("${nrsSocket}")

    code = 1
    for line in conn.makefile("rb"):
        if line.startswith(b"t3-nrs-exit "):
            code = int(line.split()[1])
            break
        sys.stdout.buffer.write(line)
        sys.stdout.flush()

    if code == 0:
        subprocess.run(["systemctl", "--user", "daemon-reload"])
        subprocess.run(["systemctl", "--user", "restart", "vicinae.service"])

    sys.exit(code)
  '';
in
{
  environment.systemPackages = [
    t3code
    nrsClient
  ];

  systemd.sockets.t3-nrs = {
    description = "Rebuild requests from T3 Code";
    wantedBy = [ "sockets.target" ];

    socketConfig = {
      ListenStream = nrsSocket;
      Accept = true;
      SocketUser = "nolight";
      SocketMode = "0600";
    };
  };

  systemd.services."t3-nrs@" = {
    description = "Rebuild NixOS for T3 Code";

    # A rebuild that changes this unit must not kill the instance that is running it.
    restartIfChanged = false;

    serviceConfig = {
      ExecStart = lib.getExe nrsGate;
      StandardInput = "socket";
      StandardOutput = "socket";
    };
  };
}
