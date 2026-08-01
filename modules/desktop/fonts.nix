{ pkgs, ... }:

{
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

      antialias = true;
      hinting = {
        enable = false;
        style = "slight";
      };
      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
      };
    };
  };
}
