{ pkgs, ... }:

# Native compiles go through rbuild, project toolchains come from devShells.
let
  # The agents repo is private, so it can't be a flake input.
  gui = pkgs.writeShellScriptBin "gui" ''
    exec nix run "path:$HOME/Projects/agents/gui" -- "$@"
  '';
  desk = pkgs.writeShellScriptBin "desk" ''
    exec ${pkgs.bash}/bin/bash "$HOME/Projects/agents/desk/desk" "$@"
  '';
in
{
  environment.systemPackages = with pkgs; [
    gui
    desk

    git
    git-lfs
    gh
    tea
    openssh
    rsync
    curl
    wget
    jq
    yq-go
    ripgrep
    fd
    bat
    btop
    htop
    fzf
    tree
    file
    which
    psmisc
    lsof
    strace
    sqlite
    zip
    unzip
    p7zip
    xz
    zstd
    vim
    just
    gnumake
    gcc
    cmake
    pkg-config
    mold
    sccache
    rustup

    nodejs_24
    bun
    pnpm
    python3
    uv
    go
    gopls

    nixfmt
    nix-output-monitor
    nix-tree
    cachix
    sops
    age

    ffmpeg
    imagemagick
  ];

  # Prebuilt binaries: T3 and its Chrome, Claude Code, Codex, rustup toolchains.
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      zstd
      curl
      openssl
      attr
      libssh
      bzip2
      libxml2
      acl
      libsodium
      util-linux
      xz
      systemd
      glib
      nss
      nspr
      atk
      at-spi2-atk
      at-spi2-core
      dbus
      expat
      alsa-lib
      libxkbcommon
      libdrm
      libgbm
      cups
      pango
      cairo
      fontconfig
      freetype
      vulkan-loader
      libx11
      libxcb
      libxcomposite
      libxdamage
      libxext
      libxfixes
      libxrandr
      libxshmfence
    ];
  };
}
