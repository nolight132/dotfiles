{ ... }:

{
  home-manager.users."nolight" = {
    xdg.configFile."ghostty/config".text = ''
      config-file = ?~/.config/ghostty/themes/matugen
      background-opacity = 0.82
      background-opacity-cells = true
      background-blur = 100
      macos-titlebar-style = hidden
      macos-option-as-alt = left
      font-size = 14
    '';
  };
}
