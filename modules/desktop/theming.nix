{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Themes
    adwaita-icon-theme
    adw-gtk3
    papirus-icon-theme
    kdePackages.qt6ct
    kdePackages.breeze
    kdePackages.breeze-icons

    # Desktop integration
    glib
    dconf
    gsettings-desktop-schemas
    matugen
  ];
}
