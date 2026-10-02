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
      # dev
      cmake
      gcc
      just
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
      nodejs
      bubblewrap
      gh
      jq
      tea
      go
      nixpkgs-review

      # user
      chafa
      ddcutil
      obs-cmd
      spotify-player
      spotatui
      ffmpeg
      fzf
      bat
      btop
      profile-sync-daemon

      inputs.nls.packages.${system}.default
      inputs.wayzoomy.packages.${system}.default
      amdgpu_top
      nvtopPackages.amd
    ]
  );
}
