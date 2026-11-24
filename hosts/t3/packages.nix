{ pkgs, ... }:

# Tools for Sonora and the other projects. Native compiles go to the buildbox through rbuild, and a
# project's own toolchain comes from its flake devShell through direnv, so this holds what agents
# run directly: git and forge clients, JavaScript and Python runtimes, Go, Nix tooling and media
# tools for screenshots and videos. rustup, rbuild and its cargo wrapper live in the home volume.
let
  # Runs gui from the agents checkout, which is private and so cannot be a flake input here. It
  # always matches the checkout and is built on first use.
  gui = pkgs.writeShellScriptBin "gui" ''
    exec nix run "path:$HOME/Projects/agents/gui" -- "$@"
  '';
in
{
  environment.systemPackages = with pkgs; [
    gui

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

  # Prebuilt binaries run through nix-ld: T3's runtime, Claude Code, Codex, rustup's toolchains and
  # the Chrome that T3 downloads for its preview.
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
