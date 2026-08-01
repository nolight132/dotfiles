{ pkgs, ... }:

{
  qt.enable = true;

  environment.sessionVariables = {
    XCURSOR_THEME = "Breeze_Light";
    XCURSOR_SIZE = "24";
  };

  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        settings."org/gnome/desktop/interface" = {
          icon-theme = "Papirus";
          font-name = "Noto Sans 10";
          document-font-name = "Noto Sans 10";
          monospace-font-name = "JetBrains Mono 10";
          font-hinting = "slight";
          font-antialiasing = "grayscale";
        };
      }
    ];
  };

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
