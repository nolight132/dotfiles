{ ... }:

let
  settings = ''
    [Settings]
    gtk-icon-theme-name=Papirus-Noctalia
    gtk-cursor-theme-name=Breeze_Light
    gtk-cursor-theme-size=24
    gtk-font-name=Noto Sans 10
    gtk-hint-font-metrics=1
  '';
in
{
  xdg.configFile."gtk-3.0/settings.ini".text = settings;
  xdg.configFile."gtk-4.0/settings.ini".text = settings;
}
