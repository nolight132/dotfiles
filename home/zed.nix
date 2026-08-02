{ config, pkgs, ... }:

let
  repo = "${config.home.homeDirectory}/Dotfiles/home/zed";
in
{
  home.packages = [ pkgs.zed-editor pkgs.nixd ];

  xdg.configFile = {
    "zed/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${repo}/settings.json";
    "zed/keymap.json".source = config.lib.file.mkOutOfStoreSymlink "${repo}/keymap.json";
  };
}
