{ pkgs, inputs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  environment.systemPackages = with pkgs; [
    ghostty
    zed-editor
    nautilus
    proton-vpn
    telegram-desktop
    vesktop
    kdePackages.filelight
    loupe
    cider-2
    obs-studio
    prismlauncher
    clapper

    inputs.zen-browser.packages.${system}.default
  ];
}
