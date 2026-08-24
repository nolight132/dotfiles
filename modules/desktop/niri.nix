{ pkgs, ... }:

{
  programs.niri.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  environment.systemPackages = with pkgs; [
    noctalia
    xwayland-satellite
    wl-clipboard
    libnotify
  ];
}
