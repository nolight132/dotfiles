{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    chezmoi
    tmux
    fastfetch
    zip
    unzip
    chafa
    gh
    nil
    bun
    ddcutil
  ];
}
