{
  inputs,
  pkgs,
  ...
}:

# NixOS in the Coolify container behind t3.nolight.dev. See README.md.
let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ../../modules/core/locale.nix
    ./packages.nix
    ./t3code.nix
  ];

  boot.isContainer = true;

  # Docker owns /etc/hostname, /etc/hosts and /etc/resolv.conf.
  networking = {
    hostName = "vps";
    useHostResolvConf = true;
    resolvconf.enable = false;
    firewall.enable = false;
  };

  # Joins the tailnet as `t3` so threads reach the desktop (see `desk` in the agents repo). Docker
  # owns resolv.conf, so names resolve through `tailscale nc` in the ssh config below.
  services.tailscale = {
    enable = true;
    extraSetFlags = [
      "--hostname=t3"
      "--accept-dns=false"
      "--operator=node"
    ];
  };
  # The node key has to outlive a redeploy, which keeps only /home/node.
  systemd.services.tailscaled.serviceConfig.BindPaths = [
    "/home/node/.local/state/tailscale:/var/lib/tailscale"
  ];

  programs.ssh.extraConfig = ''
    Host nixos
      User nolight
      IdentityFile ~/.ssh/nixos
      IdentitiesOnly yes
      StrictHostKeyChecking accept-new
      ProxyCommand tailscale nc %h %p
  '';

  # No console, and the logrotate check fails on Docker's bind mounts.
  systemd.services.console-getty.enable = false;
  services.logrotate.enable = false;

  # The default caps units at 15% of the container's 8192 pids.
  systemd.settings.Manager.DefaultTasksMax = "infinity";

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

  # Matches the owner of the existing home volume.
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

  # A fresh home volume starts out owned by root.
  systemd.tmpfiles.rules = [
    "d /home/node 0755 node node -"
    "d /home/node/projects 0755 node node -"
    "d /home/node/.local/state/tailscale 0700 root root -"
  ];

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
    # Otherwise rbuild takes the vps alias to a port closed to containers.
    RBUILD_HOST = "buildbox";
  };
  environment.localBinInPath = true;

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
