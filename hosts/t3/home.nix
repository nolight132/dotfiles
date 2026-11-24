{ lib, ... }:

# No tmux: fish.nix would start it in every T3 terminal.
{
  imports = [
    ../../home/agents.nix
    ../../home/cli.nix
    ../../home/env.nix
    ../../home/fish.nix
    ../../home/git.nix
    ../../home/starship.nix
  ];

  programs.fish.functions.nrs = lib.mkForce ''
    sudo nixos-rebuild switch --flake ~/Dotfiles#t3 $argv
  '';

  programs.git.settings.credential."https://gist.github.com".helper = "!gh auth git-credential";

  home.stateVersion = "26.05";
}
