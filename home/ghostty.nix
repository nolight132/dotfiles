{ ... }:

{
  programs.ghostty = {
    enable = true;

    settings = {
      config-file = "~/.config/ghostty/themes/matugen";
      freetype-load-flags = "no-hinting";

      background-opacity = "0.82";
      background-opacity-cells = true;

      font-family = "JetBrains Mono";
      font-style = "Medium";
      font-size = 11;
      font-feature = [
        "-calt"
        "-liga"
        "-dlig"
      ];

      adjust-cell-height = "20%";
      mouse-hide-while-typing = true;
      window-decoration = "none";
      confirm-close-surface = false;
      app-notifications = "no-clipboard-copy";
    };
  };
}
