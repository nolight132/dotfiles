{ pkgs, inputs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  environment.systemPackages = with pkgs; [
    # dev
    vim
    git
    wget
    zip
    unzip
    gh
    sccache
    pnpm
    rustc
    rust-analyzer
    nodejs

    # user
    bat
    btop
    fzf

    inputs.nls.packages.${system}.default
  ];
}
