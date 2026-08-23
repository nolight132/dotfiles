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
      sccache
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
      go

      # user
      chafa
      ddcutil
      obs-cmd
      spotify-player
      spotatui
      fzf
      bat
      btop
      profile-sync-daemon

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
