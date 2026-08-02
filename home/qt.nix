{ ... }:

{
  xdg.configFile."environment.d/qt.conf".text = ''
    QT_QPA_PLATFORMTHEME=qt6ct
  '';
}
