{ ... }:

{
  xdg.userDirs = {
    enable = true;

    desktop = "$HOME";
    publicShare = "$HOME";
    templates = "$HOME";
  };

  xdg.terminal-exec = {
    enable = true;
    settings.default = [ "com.mitchellh.ghostty.desktop" ];
  };
}
