{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    zip
    unzip
    chafa
    gh
    nil
    bun
    ddcutil
    obs-cmd
    tea
  ];
}
