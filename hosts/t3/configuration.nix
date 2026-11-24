{
  inputs,
  lib,
  pkgs,
  ...
}:

# The T3 Code server on the VPS: NixOS booted by systemd inside a privileged Docker container that
# Coolify runs as the app behind t3.nolight.dev. Image.nix turns this system into that image, and
# the README next to this file covers deploys, in-place switches and the Coolify settings.
let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ../../modules/core/locale.nix
    ./image.nix
    ./packages.nix
    ./t3code.nix
  ];

  boot.isContainer = true;

  # Docker bind-mounts /etc/hostname, /etc/hosts and /etc/resolv.conf, so these only have to agree
  # with the container's --hostname.
  networking = {
    hostName = "vps";
    useHostResolvConf = true;
    resolvconf.enable = false;
    firewall.enable = false;
  };

  # No console in a Docker container, and its logrotate check fails on the bind-mounted files.
  systemd.services.console-getty.enable = false;

  # systemd would cap every unit at 15% of the container's pids limit, a few hundred processes,
  # which a T3 server running several agents outgrows. Docker's --pids-limit is the cap instead.
  systemd.settings.Manager.DefaultTasksMax = "infinity";
  services.logrotate.enable = false;

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        "node"
      ];
      extra-substituters = [ "https://sonora.cachix.org" ];
      extra-trusted-public-keys = [
        "sonora.cachix.org-1:qbPeDsvZPbwUWHpQS5Oe0bjz5oHAVscHem+MCzwrc9Q="
      ];
      warn-dirty = false;
      max-jobs = 4;
      cores = 4;
    };

    # `nixpkgs#foo` resolves to this system's nixpkgs, which is already in the store.
    registry.nixpkgs.flake = inputs.nixpkgs;
    nixPath = [ "nixpkgs=flake:nixpkgs" ];

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
    optimise.automatic = true;
  };

  nixpkgs.config.allowUnfree = true;

  # uid and gid 1000 own everything in the home volume from the Debian image this replaced.
  users.groups.node.gid = 1000;
  users.users.node = {
    isNormalUser = true;
    uid = 1000;
    group = "node";
    home = "/home/node";
    createHome = false;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
    linger = true;
  };
  security.sudo.wheelNeedsPassword = false;

  systemd.tmpfiles.rules = [ "d /home/node/projects 0755 node node -" ];

  programs.fish.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-bak";
    extraSpecialArgs = { inherit inputs; };
    users.node = import ./home.nix;
  };

  environment.sessionVariables = {
    NPM_CONFIG_PREFIX = "$HOME/.local";
  };

  environment.systemPackages = [ inputs.nls.packages.${system}.default ];

  fonts = {
    fontconfig.enable = true;
    packages = with pkgs; [
      dejavu_fonts
      liberation_ttf
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];
  };

  system.stateVersion = "26.05";
}
