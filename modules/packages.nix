{ pkgs, inputs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  environment.systemPackages = with pkgs; [
    # Core tools
    vim
    wget
    git
    chezmoi
    tmux
    fzf
    zoxide
    starship
    atuin
    fastfetch
    zip
    unzip

    # Desktop apps
    ghostty
    zed-editor
    vicinae
    nautilus
    proton-vpn
    telegram-desktop
    discord
    claude-code

    # Desktop integration
    glib
    dconf
    gsettings-desktop-schemas
    pulseaudio
    matugen

    # Themes
    adwaita-icon-theme
    adw-gtk3
    papirus-icon-theme
    kdePackages.qt6ct
    kdePackages.breeze
    kdePackages.breeze-icons

    # Flake packages
    inputs.zen-browser.packages.${system}.default
    inputs.noctalia.packages.${system}.default
  ];
}
