{ ... }:

{
  home-manager.users."nolight" = {
    xdg.configFile."ghostty/config".text = ''
      macos-option-as-alt = left
      font-size = 14
    '';
  };
}
