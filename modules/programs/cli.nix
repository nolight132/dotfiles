{ pkgs, lib, ... }:

{
  environment.systemPackages =
    (with pkgs; [
      vim
      wget
      git
      zip
      unzip
      chafa
      gh
      bun
      ddcutil
      obs-cmd
      tea
      codex
      cmake
      gcc
      rustc
      cargo
      uv
      spotify-player
      spotatui
    ])
    ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 (
      with pkgs;
      [
        amdgpu_top
      ]
    )
    ++ lib.optionals pkgs.stdenv.hostPlatform.isAarch64 (
      with pkgs;
      [
        upower
      ]
    );
}
