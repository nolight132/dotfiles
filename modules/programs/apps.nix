{
  pkgs,
  lib,
  inputs,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  environment.systemPackages =
    (with pkgs; [
      nautilus
      proton-vpn
      telegram-desktop
      vesktop
      kdePackages.filelight
      loupe
      obs-studio
      prismlauncher
      clapper
      file-roller
      ffmpegthumbnailer
      evince
      tumbler
      sushi
      video-trimmer
      krita

      inputs.zen-browser.packages.${system}.default
      inputs.sonora.packages.${system}.sonora-bin
    ])
    ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 (
      with pkgs;
      [
        (pkgs.discord.override {
          withVencord = true;
        })
        reaper
        slack
        spotify
      ]
    )
    ++ lib.optionals pkgs.stdenv.hostPlatform.isAarch64 (
      with pkgs;
      [
        kdePackages.dolphin
      ]
    );
}
