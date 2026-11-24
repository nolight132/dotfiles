{ lib, pkgs, ... }:

# T3, Claude Code and Codex live in ~/.local and update themselves.
let
  home = "/home/node";

  path = lib.concatStringsSep ":" [
    "${home}/.local/bin"
    "${home}/.cargo/bin"
    "${home}/.bun/bin"
    "${home}/.nix-profile/bin"
    "/etc/profiles/per-user/node/bin"
    "/run/wrappers/bin"
    "/run/current-system/sw/bin"
  ];

  # Keeps the installed version when the registry is unreachable.
  install = pkgs.writeShellScript "t3-install" ''
    set -u
    want=$(npm view "t3@''${T3_CHANNEL:-latest}" version 2>/dev/null || true)
    have=$(t3 --version 2>/dev/null | sed 's/^t3 v//' || true)
    if [ -n "$want" ] && [ "$want" != "$have" ]; then
      npm install -g "t3@$want" || [ -n "$have" ]
    elif [ -z "$have" ]; then
      echo "t3: no version installed and the registry is unreachable" >&2
      exit 1
    fi
    command -v claude >/dev/null || npm install -g @anthropic-ai/claude-code || true
    command -v codex >/dev/null || npm install -g @openai/codex || true
  '';
in
{
  systemd.services.t3 = {
    description = "T3 Code server";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [
      "network-online.target"
      "nix-daemon.socket"
      "home-manager-node.service"
    ];

    # Keeps the thread that runs nrs alive.
    restartIfChanged = false;

    path = lib.mkForce [ ];
    environment = {
      PATH = lib.mkForce path;
      HOME = home;
      USER = "node";
      SHELL = "/run/current-system/sw/bin/fish";
      LANG = "en_US.UTF-8";
      T3CODE_HOME = "${home}/.t3";
      NPM_CONFIG_PREFIX = "${home}/.local";
      NIX_PATH = "nixpkgs=flake:nixpkgs";
      RBUILD_HOST = "buildbox";
    };

    serviceConfig = {
      User = "node";
      Group = "node";
      WorkingDirectory = "${home}/projects";
      # Coolify's variables arrive as the container's environment.
      PassEnvironment = [
        "T3_CHANNEL"
        "CLAUDE_CODE_OAUTH_TOKEN"
        "ANTHROPIC_API_KEY"
        "OPENAI_API_KEY"
      ];
      ExecStartPre = install;
      ExecStart = "${home}/.local/bin/t3 serve --host 0.0.0.0 --port 3773 --no-browser";
      Restart = "always";
      RestartSec = 5;
      TimeoutStartSec = "10min";
      LimitNOFILE = 1048576;
      TasksMax = "infinity";
    };
  };
}
