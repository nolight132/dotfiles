{ config, pkgs, ... }:

let
  repo = "${config.home.homeDirectory}/Dotfiles/home/noctalia";
in
{
  xdg.configFile."noctalia/hooks/matugen.sh" = {
    source = ./noctalia/matugen.sh;
    executable = true;
  };

  xdg.configFile."noctalia/nix-snowflake.svg".source =
    "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake-white.svg";

  xdg.stateFile."noctalia/settings.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${repo}/settings.toml";

  xdg.stateFile."noctalia/.setup-complete".text = "";
}
