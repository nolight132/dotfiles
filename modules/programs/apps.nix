{
  pkgs,
  inputs,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;
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
      chromium
      firefox
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
      inputs.delta.packages.${system}.delta
      bruno
      godot

      # Communication
      telegram-desktop
      vesktop
      (pkgs.discord.override {
        withVencord = true;
      })
      element-desktop

      # Music
      reaper
      ratatouille-lv2
      guitarix-vst
      spotify
      inputs.sonora.packages.${system}.default

      # Gaming
      osu-lazer-bin
      prismlauncher
      inputs.horizon-launcher.packages.${system}.default

      # Misc
      obs-studio
      krita
      aseprite
      inputs.photocraft.packages.${system}.default
      shotcut
      qbittorrent
      proton-vpn
      mangohud
      openjdk25

      # Uni bullshit (doesn't even fucking work)
      # cisco-packet-tracer_9
    ]
  );
}
