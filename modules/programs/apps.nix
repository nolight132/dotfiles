{ pkgs, inputs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  environment.systemPackages = with pkgs; [
    ghostty
    zed-editor
    vicinae
    nautilus
    proton-vpn
    telegram-desktop
    discord
    claude-code

    inputs.zen-browser.packages.${system}.default
  ];
}
