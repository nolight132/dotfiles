{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:

let
  mutableKdl = "screencast-privacy.kdl";
  kdlFiles = builtins.attrNames (
    lib.filterAttrs (n: t: t == "regular" && lib.hasSuffix ".kdl" n && n != mutableKdl) (
      builtins.readDir ./niri
    )
  );
  ruleFile = "${config.xdg.configHome}/niri/${mutableKdl}";

  # A double tick built from the Yaru volume click, with the second tick pitched down. It is
  # resampled to 48 kHz because a 44.1 kHz stream makes PipeWire switch the device rate, which
  # swallows a sound this short.
  screenshotTick =
    pkgs.runCommand "screenshot-tick.wav" { nativeBuildInputs = [ pkgs.ffmpeg-headless ]; }
      ''
        ffmpeg -hide_banner -loglevel error \
          -i ${pkgs.yaru-theme}/share/sounds/Yaru/stereo/audio-volume-change.oga \
          -filter_complex "[0]aresample=48000,asplit[a][b];[b]asetrate=48000*0.75,aresample=48000,adelay=70:all=1[c];[a][c]amix=inputs=2:normalize=0,apad=pad_dur=0.05" \
          -ar 48000 $out
      '';

  # Plays the screenshot tick for every screenshot niri reports on its event stream.
  screenshotSound = pkgs.writeShellApplication {
    name = "niri-screenshot-sound";
    runtimeInputs = [
      osConfig.programs.niri.package
      pkgs.jq
      pkgs.pipewire
    ];
    text = ''
      niri msg --json event-stream \
        | jq --unbuffered -c 'select(has("ScreenshotCaptured"))' \
        | while read -r _; do
          pw-play --volume 0.6 ${screenshotTick} &
        done
    '';
  };
in
{
  xdg.configFile =
    (lib.listToAttrs (map (n: lib.nameValuePair "niri/${n}" { source = ./niri + "/${n}"; }) kdlFiles))
    // {
      "niri/scripts/toggle-telegram-screencast.sh" = {
        source = ./niri/scripts/toggle-telegram-screencast.sh;
        executable = true;
      };
    };

  # runtime mutable
  home.activation.niriScreencastPrivacy = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    if [ -L "${ruleFile}" ]; then
      run rm -f "${ruleFile}"
    fi
    if [ ! -e "${ruleFile}" ]; then
      run install -Dm644 ${./niri + "/${mutableKdl}"} "${ruleFile}"
    fi
  '';

  systemd.user.services.niri-screenshot-sound = {
    Unit = {
      Description = "Screenshot sound for niri";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = lib.getExe screenshotSound;
      Restart = "on-failure";
      RestartSec = 1;
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}
