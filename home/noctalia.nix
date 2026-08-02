{ config, osConfig, ... }:

let
  repo = "${config.home.homeDirectory}/Dotfiles/home/noctalia";
in
{
  xdg.configFile."noctalia/hooks/matugen.sh" = {
    source = ./noctalia/matugen.sh;
    executable = true;
  };

  # Noctalia 5 keeps its live config in XDG_STATE_HOME and rewrites the whole
  # file on every change, so it has to be an out-of-store symlink into the repo.
  # Per-host, since the monitor names differ (nixos: DP-1/DP-2, macbook: eDP-1).
  xdg.stateFile."noctalia/settings.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${repo}/settings.${osConfig.networking.hostName}.toml";

  # Without this marker noctalia replays its first-start setup wizard.
  xdg.stateFile."noctalia/.setup-complete".text = "";
}
