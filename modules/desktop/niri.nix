{ pkgs, ... }:

{
  programs.niri.enable = true;
  programs.fish.enable = true;

  services.greetd.enable = true;
  services.greetd.settings.default_session.command =
    "${pkgs.tuigreet}/bin/tuigreet --cmd niri-session";

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
}
