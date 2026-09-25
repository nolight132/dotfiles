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
      ffmpegthumbnailer
      tumbler
      evince
      sushi
      video-trimmer
      loupe
      kdePackages.filelight

      # Browsers
      chromium
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

      # Misc
      obs-studio
      krita
      shotcut
      qbittorrent
      proton-vpn
      inputs.t3code.packages.${system}.default
      bruno
    ]
  );
}
