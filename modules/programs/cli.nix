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
      # dev
      cmake
      gcc
      rustc
      cargo
      rustfmt
      clippy
      rust-analyzer
      rustPlatform.rustLibSrc
      gopls
      uv
      vim
      wget
      git
      zip
      unzip
      bun
      gh
      tea

      # user
      chafa
      ddcutil
      obs-cmd
      codex
      spotify-player
      spotatui
      fzf
      bat
      btop

      inputs.nls.packages.${system}.default
      inputs.wayzoomy.packages.${system}.default
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
