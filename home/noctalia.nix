{ config, osConfig, ... }:

let
  repo = "${config.home.homeDirectory}/Dotfiles/home/noctalia";
in
{
  xdg.configFile."noctalia/hooks/matugen.sh" = {
    source = ./noctalia/matugen.sh;
    executable = true;
  };

  xdg.stateFile."noctalia/settings.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${repo}/settings.${osConfig.networking.hostName}.toml";

  xdg.stateFile."noctalia/.setup-complete".text = "";
}
