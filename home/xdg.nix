{ config, ... }:

{
  xdg.userDirs = {
    enable = true;

    desktop = config.home.homeDirectory;
    publicShare = config.home.homeDirectory;
    templates = config.home.homeDirectory;
  };

  xdg.terminal-exec = {
    enable = true;
    settings.default = [ "com.mitchellh.ghostty.desktop" ];
  };
}
