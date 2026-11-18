{
  lib,
  pkgs,
  inputs,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;

  reaper = pkgs.symlinkJoin {
    name = "reaper";
    paths = [ (pkgs.reaper.override { jackLibrary = pkgs.pipewire.jack; }) ];

    nativeBuildInputs = [ pkgs.makeWrapper ];

    postBuild = ''
      wrapProgram $out/bin/reaper \
        --run '${lib.getExe pkgs.yabridgectl} sync --prune >/dev/null 2>&1 || true'
    '';
  };
in
{
  environment.systemPackages = (
    with pkgs;
    [
      # System
      nautilus
      clapper
      file-roller
      libreoffice
      ffmpegthumbnailer
      tumbler
      evince
      sushi
      video-trimmer
      loupe
      kdePackages.filelight

      # Browsers
      inputs.helium.packages.${system}.default
      (pkgs.symlinkJoin {
        name = "zen-browser";
        paths = [ inputs.zen-browser.packages.${system}.default ];

        nativeBuildInputs = [ pkgs.makeWrapper ];

        postBuild = ''
          wrapProgram $out/bin/zen \
            --set MOZ_GTK_TITLEBAR_DECORATION none
        '';
      })

      # Development
      bruno
      godot

      # Communication
      telegram-desktop
      vesktop
      element-desktop

      # Music
      reaper
      yabridge
      yabridgectl
      wineWow64Packages.yabridge
      ratatouille-lv2
      neural-amp-modeler-lv2
      neuralrack
      calf
      guitarix-vst
      spotify
      inputs.sonora.packages.${system}.default

      # Gaming
      osu-lazer-bin
      prismlauncher
      vinegar

      # Misc
      obs-studio
      krita
      aseprite
      inputs.photocraft.packages.${system}.default
      qbittorrent
      proton-vpn
      mangohud
      openjdk25

      # Uni bullshit (doesn't even fucking work)
      # cisco-packet-tracer_9
    ]
  );
}
