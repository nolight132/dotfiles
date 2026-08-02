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
    bun
    ddcutil
    obs-cmd
    tea
    codex
    amdgpu_top
  ];
}
