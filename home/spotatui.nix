{ pkgs, ... }:

let
  appId = "com.mitchellh.ghostty.spotatui";
in
{
  xdg.desktopEntries.spotatui = {
    name = "Spotatui";
    genericName = "Spotify Client";
    comment = "Fully standalone Spotify client for the terminal";
    icon = "spotify-client";
    exec = "${pkgs.ghostty}/bin/ghostty --class=${appId} --title=Spotatui -e ${pkgs.spotatui}/bin/spotatui";
    terminal = false;
    type = "Application";
    categories = [
      "AudioVideo"
      "Audio"
      "Player"
    ];
    startupNotify = true;
    settings.StartupWMClass = appId;
  };
}
