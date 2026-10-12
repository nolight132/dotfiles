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
    tea
    cmake
    jdk21
    (google-cloud-sdk.withExtraComponents [
      google-cloud-sdk.components.cloud-firestore-emulator
    ])
    (python3.withPackages (ps: [
      ps.fonttools
      ps.brotli
    ]))

    # user
    bat
    btop
    fzf

    inputs.nls.packages.${system}.default
  ];
}
