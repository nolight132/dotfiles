{ ... }:

{
  home-manager.users."nolight" =
    { config, pkgs, ... }:
    let
      repo = "${config.home.homeDirectory}/Dotfiles/home/zed";
      app = "${config.home.homeDirectory}/${config.targets.darwin.copyApps.directory}/Zed.app";

      # The cli opens the bundle it ships in, which is not the copy Home Manager installs. When
      # that copy is already running, the cli never gets its handshake and hangs.
      zed-editor = pkgs.symlinkJoin {
        inherit (pkgs.zed-editor) name meta;
        paths = [ pkgs.zed-editor ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/zeditor --add-flag --zed --add-flag "${app}"
        '';
      };
    in
    {
      home.packages = [
        zed-editor
        pkgs.nixd
        pkgs.nixfmt
      ];

      xdg.configFile = {
        "zed/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${repo}/settings.json";
        "zed/keymap.json".source = config.lib.file.mkOutOfStoreSymlink "${repo}/keymap.json";
      };
    };
}
