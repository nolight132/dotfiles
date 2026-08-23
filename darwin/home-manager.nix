{ inputs, ... }:

{
  imports = [ inputs.home-manager.darwinModules.home-manager ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    backupFileExtension = "hm-bak";

    extraSpecialArgs = { inherit inputs; };

    users."nolight" =
      { config, lib, ... }:
      {
        imports = [
          ../home/atuin.nix
          ../home/cli.nix
          ../home/env.nix
          ../home/fish.nix
          ../home/git.nix
          ../home/starship.nix
          ../home/tmux.nix
        ];

        home.stateVersion = "26.05";

        programs.man.generateCaches = false;

        programs.fish.functions.nrs = lib.mkForce ''
          sudo darwin-rebuild switch --flake ~/Dotfiles#macbook-air $argv
        '';

        programs.fish.shellAliases.files = lib.mkForce "open .";

        home.sessionVariables = {
          PNPM_HOME = "${config.home.homeDirectory}/Library/pnpm";
          GOBIN = lib.mkForce "${config.home.homeDirectory}/.local/share/go/bin";
        };

        home.sessionPath = [
          "${config.home.homeDirectory}/Library/pnpm"
          "/etc/profiles/per-user/nolight/bin"
          "/run/current-system/sw/bin"
          "/nix/var/nix/profiles/default/bin"
        ];

        programs.fish.loginShellInit = lib.mkAfter ''
          if test -d /opt/homebrew/bin; and not contains /opt/homebrew/bin $PATH
              set -ga PATH /opt/homebrew/bin /opt/homebrew/sbin
          end
        '';
      };
  };
}
