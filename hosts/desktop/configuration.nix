{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules
  ];

  boot.ketnelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos";
  system.stateVersion = "26.05";
}
