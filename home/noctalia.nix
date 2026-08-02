{ config, ... }:

let
  repo = "${config.home.homeDirectory}/Dotfiles/home/noctalia";
in
{
  xdg.configFile = {
    "noctalia/hooks/matugen.sh" = {
      source = ./noctalia/matugen.sh;
      executable = true;
    };

    "noctalia/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${repo}/settings.json";
    "noctalia/colors.json".source = config.lib.file.mkOutOfStoreSymlink "${repo}/colors.json";
    "noctalia/plugins.json".source = config.lib.file.mkOutOfStoreSymlink "${repo}/plugins.json";
  };
}
