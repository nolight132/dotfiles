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
      spotatui
      cmake
      gcc
      rustc
      cargo
      uv
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
