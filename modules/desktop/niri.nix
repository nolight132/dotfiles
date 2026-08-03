{ pkgs, ... }:

{
  programs.niri.enable = true;

  services.greetd.enable = true;
  services.greetd.settings.default_session.command =
    "${pkgs.tuigreet}/bin/tuigreet --remember --cmd niri-session";

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
