{ ... }:

{
  programs.kitty = {
    enable = true;

    settings = {
      font_family = ''family="JetBrains Mono" style=Medium'';
      font_size = 11;
      disable_ligatures = "always";
      modify_font = "cell_height 120%";

      background_opacity = "0.82";
      hide_window_decorations = true;
      confirm_os_window_close = 0;
      mouse_hide_wait = "3.0";
    };

    extraConfig = ''
      include ~/.config/kitty/themes/matugen.conf
    '';
  };
}
