{ pkgs, ... }:

let
  # GTK 4 indexes every icon of a theme on startup, so keep only what Nautilus and the
  # dock need: 16, 24 and 48 px, with app icons at 48 px only. 32x32/symbolic links to the
  # unpadded 16 px art and stays because Noctalia's tray takes the largest symbolic size.
  papirus-trimmed =
    pkgs.runCommand "papirus-icon-theme-trimmed" { nativeBuildInputs = [ pkgs.gtk3 ]; }
      ''
        for theme in Papirus Papirus-Dark; do
          src=${pkgs.papirus-icon-theme}/share/icons/$theme
          dst=$out/share/icons/$theme
          mkdir -p $dst
          cp -a $src/{16x16,24x24,48x48} $dst/
          mkdir -p $dst/32x32
          cp -a $src/32x32/symbolic $dst/32x32/
          chmod -R u+w $dst
          rm -rf $dst/{16x16,24x24}/apps $dst/*/categories
          find $dst -xtype l | while read -r link; do
            cp --remove-destination "$(readlink -f "$src''${link#$dst}")" "$link"
          done

          dirs=$(grep '^Directories=' $src/index.theme | cut -d= -f2 | tr , '\n' \
            | while read -r d; do if [ -e "$dst/$d" ]; then echo "$d"; fi; done | paste -sd,)
          sed -e "s|^Directories=.*|Directories=$dirs|" -e '/^ScaledDirectories=/d' \
            $src/index.theme > $dst/index.theme
          gtk-update-icon-cache -q $dst
        done
      '';

  papirus-noctalia =
    let
      papirus = "${papirus-trimmed}/share/icons/Papirus-Dark";

      index = pkgs.writeText "index.theme" ''
        [Icon Theme]
        Name=Papirus-Noctalia
        Inherits=Papirus-Dark,hicolor
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
      ln -s ${papirus}/48x48/apps/zen-browser.svg $dir/zen.svg
      ln -s ${papirus}/48x48/apps/cider.svg $dir/cider-2.svg
      ln -s ${papirus}/48x48/apps/discord.svg $dir/vesktop.svg
    '';
in
{
  qt.enable = true;
  gtk.iconCache.enable = true;

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
        locks = [ "/org/gnome/desktop/interface/icon-theme" ];

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
    papirus-trimmed
    papirus-noctalia
    kdePackages.qt6ct
    kdePackages.breeze
    kdePackages.breeze-icons
    glib
    dconf
    gsettings-desktop-schemas
  ];
}
