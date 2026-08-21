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
      inputs.zen-browser.packages.${system}.default

      # Communication
      telegram-desktop
      vesktop
      (pkgs.discord.override {
        withVencord = true;
      })
      slack

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
      qbittorrent
      proton-vpn
    ]
  );
}
