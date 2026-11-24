{ lib, pkgs, ... }:

# Runs `t3 serve` as node on port 3773, where Coolify's proxy sends t3.nolight.dev. T3, Claude Code
# and Codex are npm packages in ~/.local, so they survive redeploys and can update themselves. The
# T3 version follows the T3_CHANNEL variable that Coolify sets on the container.
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

  # Installs T3 when the wanted version is missing and Claude Code or Codex when either is absent.
  # A failed lookup keeps whatever is installed, so the server still starts without the registry.
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

    # A switch from inside a T3 thread would otherwise kill that thread. The new generation takes
    # over at the next container restart or `systemctl restart t3`.
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
      # Coolify's variables reach systemd as the container's environment, and services see only
      # the ones named here.
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
