{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos";
  system.stateVersion = "26.05";

  swapDevices = [
    {
      device = "/swapfile";
      size = 8 * 1024;
    }
  ];

  fileSystems."/nix".options = [
    "subvol=nix"
    "compress=zstd"
  ];

  fileSystems."/home".options = [
    "subvol=home"
    "compress=zstd"
  ];

  fileSystems."/".options = [
    "compress=zstd"
  ];
}
