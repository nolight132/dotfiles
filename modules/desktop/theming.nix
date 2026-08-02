{ pkgs, ... }:

let
  # Papirus ships zen-browser.svg and cider.svg, but the installed desktop
  # entries are zen.desktop (Icon=zen) and cider-2.desktop (Icon=cider-2), so
  # those two fall back to their bundled icons. Alias them in an inheriting
  # theme rather than renaming the dock entries, which would break launching.
  papirus-noctalia =
    let
      papirus = "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark";

      index = pkgs.writeText "index.theme" ''
        [Icon Theme]
        Name=Papirus-Noctalia
        Inherits=Papirus-Dark,Papirus,hicolor
        Directories=scalable/apps

        [scalable/apps]
        Context=Applications
        Type=Scalable
        Size=64
        MinSize=8
        MaxSize=512
      '';
    in
    pkgs.runCommand "papirus-noctalia-icon-theme" { } ''
      dir=$out/share/icons/Papirus-Noctalia/scalable/apps
      mkdir -p $dir
      cp ${index} $out/share/icons/Papirus-Noctalia/index.theme
      ln -s ${papirus}/64x64/apps/zen-browser.svg $dir/zen.svg
      ln -s ${papirus}/64x64/apps/cider.svg $dir/cider-2.svg
    '';
in
{
  qt.enable = true;

  environment.sessionVariables = {
    XCURSOR_THEME = "Breeze_Light";
    XCURSOR_SIZE = "24";

    XDG_DATA_DIRS = [
      "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
    ];
  };

  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        settings."org/gnome/desktop/interface" = {
          icon-theme = "Papirus-Noctalia";
          font-name = "Noto Sans 10";
          document-font-name = "Noto Sans 10";
          monospace-font-name = "JetBrains Mono 10";
          font-hinting = "none";
          font-antialiasing = "grayscale";
        };
      }
    ];
  };

  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    adw-gtk3
    papirus-icon-theme
    papirus-noctalia
    kdePackages.qt6ct
    kdePackages.breeze
    kdePackages.breeze-icons
    glib
    dconf
    gsettings-desktop-schemas
    matugen
  ];
}
