{ ... }:

{
  home-manager.users."nolight" =
    { config, pkgs, ... }:
    let
      home = config.home.homeDirectory;
      templates = ../home/noctalia/templates;
      zedTheme = "${home}/.config/zed/themes/rosepuccin.json";

      matugenConfig = (pkgs.formats.toml { }).generate "matugen-config.toml" {
        config = {
          wallpaper_tool = "None";
          custom_colors.green = {
            color = "#3fb950";
            blend = true;
          };
        };

        colors.terminal_colors = true;

        templates = {
          ghostty = {
            input_path = "${templates}/ghostty.conf";
            output_path = "${home}/.config/ghostty/themes/matugen";
            post_hook = "/usr/bin/pkill -SIGUSR2 -x ghostty || true";
          };

          zed = {
            input_path = "${templates}/zed.json";
            output_path = zedTheme;
            post_hook = "${pkgs.jq}/bin/jq '(.themes[] | select(.name | endswith(\"Transparent\")) | .style[\"background.appearance\"]) = \"blurred\"' ${zedTheme} > ${zedTheme}.tmp && mv ${zedTheme}.tmp ${zedTheme}";
          };
        };
      };

      matugenWallpaper = pkgs.writeShellApplication {
        name = "matugen-wallpaper";
        runtimeInputs = [
          pkgs.matugen
          pkgs.coreutils
        ];
        text = ''
          state=${home}/.local/state/matugen
          mkdir -p "$state"

          wallpaper=$(/usr/bin/osascript -e 'tell application "System Events" to get picture of desktop 1') || {
            echo "matugen: cannot read the current wallpaper" >&2
            exit 0
          }
          [[ -f $wallpaper ]] || exit 0

          key="$wallpaper $(stat -c %Y "$wallpaper") ${matugenConfig}"
          [[ ''${1-} == --force || $(cat "$state/last" 2>/dev/null) != "$key" ]] || exit 0

          echo "matugen: theming from $wallpaper"
          matugen --config ${matugenConfig} image --mode dark --source-color-index 0 -- "$wallpaper"
          printf '%s\n' "$key" > "$state/last"
        '';
      };
    in
    {
      home.packages = [
        pkgs.matugen
        matugenWallpaper
      ];

      xdg.configFile."matugen/config.toml".source = matugenConfig;
      home.file.".local/state/matugen/.keep".text = "";

      launchd.agents.matugen-wallpaper = {
        enable = true;
        config = {
          ProgramArguments = [ "${matugenWallpaper}/bin/matugen-wallpaper" ];
          RunAtLoad = true;
          StartInterval = 30;
          WatchPaths = [ "${home}/Library/Application Support/com.apple.wallpaper/Store/Index.plist" ];
          StandardOutPath = "${home}/.local/state/matugen/log";
          StandardErrorPath = "${home}/.local/state/matugen/log";
        };
      };
    };
}
