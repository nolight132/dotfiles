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
      video-trimmer

      inputs.zen-browser.packages.${system}.default
    ])
    ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 (
      with pkgs;
      [
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
