{ pkgs, ... }:

{
  # Session
  programs.niri.enable = true;
  programs.fish.enable = true;

  services.greetd.enable = true;
  services.greetd.settings.default_session.command =
    "${pkgs.tuigreet}/bin/tuigreet --cmd niri-session";

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Portals
  xdg.portal = {
    enable = true;

    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];

    config.common.default = [
      "gnome"
      "gtk"
    ];
  };

  # Fonts
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      liberation_ttf
      jetbrains-mono
    ];

    fontconfig = {
      enable = true;

      defaultFonts = {
        sansSerif = [ "Noto Sans" ];
        serif = [ "Noto Serif" ];
        monospace = [ "JetBrains Mono" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
