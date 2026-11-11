{ pkgs, inputs, ... }:

let
  upstream = inputs.t3code.packages.${pkgs.stdenv.hostPlatform.system}.t3code-nightly;

  rootBackground = "<style>html.dark body,body{background:transparent!important}html[data-theme-id]{background:var(--app-chrome-background)!important;--surface-grain:none!important}html[data-theme-id] main[data-slot=sidebar-inset],html[data-theme-id] [data-app-sidebar]{--background:transparent!important}</style>";

  # Chromium counts the Mod key as keyboard input, so every press would ring the focused workspace region.
  hideWorkspaceRing = "<style>[data-workspace-area]:focus-visible{outline:none!important}</style>";

  contents =
    pkgs.runCommand "${upstream.name}-transparent-extracted" { nativeBuildInputs = [ pkgs.asar ]; }
      ''
        cp -r ${upstream.contents} $out
        chmod -R u+w $out

        asar extract $out/resources/app.asar $out/resources/app
        rm -r $out/resources/app.asar $out/resources/app.asar.unpacked

        substituteInPlace $out/resources/app/apps/desktop/dist-electron/main.cjs \
          --replace-fail 'return shouldUseDarkColors ? "#000000" : "#ffffff";' 'return "#00000000";' \
          --replace-fail 'minHeight: MIN_MAIN_WINDOW_SIZE.height,' 'minHeight: MIN_MAIN_WINDOW_SIZE.height, transparent: true,'

        substituteInPlace $out/resources/app/apps/server/dist/client/index.html \
          --replace-fail '</head>' '${rootBackground}${hideWorkspaceRing}</head>'
      '';

  t3code = pkgs.appimageTools.wrapAppImage {
    inherit (upstream) pname version meta;
    src = contents;

    extraPkgs = pkgs: [ pkgs.libsecret ];

    extraInstallCommands = ''
      cp -r ${upstream}/share $out/
    '';
  };
in
{
  environment.systemPackages = [ t3code ];
}
