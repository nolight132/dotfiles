{ lib, ... }:

# The shell and git setup of the desktop, without its desktop parts. tmux stays out because fish.nix
# would start it in every terminal T3 opens.
{
  imports = [
    ../../home/agents.nix
    ../../home/cli.nix
    ../../home/env.nix
    ../../home/fish.nix
    ../../home/git.nix
    ../../home/starship.nix
  ];

  # Switches in place. The T3 server keeps running on the old generation until the container
  # restarts, so the thread that runs this survives it.
  programs.fish.functions.nrs = lib.mkForce ''
    sudo nixos-rebuild switch --flake ~/Dotfiles#t3 $argv
  '';

  programs.git.settings.credential."https://gist.github.com".helper = "!gh auth git-credential";

  home.stateVersion = "26.05";
}
