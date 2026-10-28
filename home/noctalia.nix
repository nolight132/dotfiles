{
  config,
  lib,
  pkgs,
  ...
}:

let
  repo = "${config.home.homeDirectory}/Dotfiles/home/noctalia";
  configHome = config.xdg.configHome;
  templates = ./noctalia/templates;
  openrgbScript = "${configHome}/OpenRGB/rosepuccin.sh";
  keyboardScript = "${configHome}/g75-cli/rosepuccin.sh";

  # Noctalia renders these with the active palette whenever it changes, so every app follows
  # the shell's colours whether they come from the wallpaper or a fixed palette.
  templatesConfig = (pkgs.formats.toml { }).generate "noctalia-templates.toml" {
    theme.templates = {
      custom_colors = {
        green = {
          color = "#3fb950";
          blend = true;
        };

        warning = {
          color = "#fe9a00";
          blend = true;
        };
      };

      user = {
        ghostty = {
          input_path = "${templates}/ghostty.conf";
          output_path = "${configHome}/ghostty/themes/rosepuccin";
          post_hook = "pkill -SIGUSR2 ghostty || true";
        };

        kitty = {
          input_path = "${templates}/kitty.conf";
          output_path = "${configHome}/kitty/themes/rosepuccin.conf";
          post_hook = "pkill -SIGUSR1 kitty || true";
        };

        zed = {
          input_path = "${templates}/zed.json";
          output_path = "${configHome}/zed/themes/rosepuccin.json";
        };

        # T3 Code watches its themes directory and reloads this file live. Select it once with
        # `t3 theme set rosepuccin`.
        t3code = {
          input_path = "${templates}/t3code.json";
          output_path = "${config.home.homeDirectory}/.t3/userdata/themes/rosepuccin.json";
        };

        gtk3 = {
          input_path = "${templates}/gtk-3.0/gtk.css";
          output_path = "${configHome}/gtk-3.0/gtk.css";
        };

        gtk3_colors = {
          input_path = "${templates}/gtk-3.0/colors.css";
          output_path = "${configHome}/gtk-3.0/colors.css";
        };

        gtk4 = {
          input_path = "${templates}/gtk-4.0/gtk.css";
          output_path = "${configHome}/gtk-4.0/gtk.css";
        };

        gtk4_colors = {
          input_path = "${templates}/gtk-4.0/colors.css";
          output_path = "${configHome}/gtk-4.0/colors.css";
        };

        openrgb = {
          input_path = "${templates}/openrgb.sh";
          output_path = openrgbScript;
          post_hook = "sh ${openrgbScript}";
        };

        keyboard = {
          input_path = "${templates}/g75.sh";
          output_path = keyboardScript;
          post_hook = "sh ${keyboardScript}";
        };

        qt6ct = {
          input_path = "${templates}/qt6ct.conf";
          output_path = "${configHome}/qt6ct/colors/rosepuccin.conf";
        };

        kdeglobals = {
          input_path = "${templates}/kdeglobals";
          output_path = "${configHome}/kdeglobals";
        };
      };
    };
  };
in
{
  home.packages = [
    pkgs.cosmic-sound-theme
    pkgs.pantheon.elementary-sound-theme
    pkgs.yaru-theme
  ];

  xdg.configFile."noctalia/templates.toml".source = templatesConfig;

  xdg.configFile."noctalia/nix-snowflake.svg".source =
    "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake-white.svg";

  xdg.stateFile."noctalia/settings.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${repo}/settings.toml";

  xdg.stateFile."noctalia/.setup-complete".text = "";

  # Applies the last rendered colour to the RGB devices at login. It retries until the OpenRGB
  # server has finished detecting devices, because the script fails while either device is missing.
  systemd.user.services.openrgb-theme = {
    Unit = {
      Description = "Apply the theme colour to OpenRGB devices";
      ConditionPathExists = openrgbScript;
      StartLimitIntervalSec = 120;
      StartLimitBurst = 30;
    };

    Service = {
      Type = "oneshot";
      Environment = "PATH=${
        lib.makeBinPath [
          pkgs.gawk
          pkgs.openrgb
        ]
      }";
      ExecStart = "${pkgs.runtimeShell} ${openrgbScript}";
      Restart = "on-failure";
      RestartSec = 3;
    };

    Install.WantedBy = [ "default.target" ];
  };
}
