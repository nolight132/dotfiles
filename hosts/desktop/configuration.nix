{ pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules
  ];

  boot.kernelPackages = inputs.kernel-nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.linuxPackages_latest;

  networking.hostName = "nixos";
  system.stateVersion = "26.05";

  swapDevices = [
    {
      device = "/swapfile";
      size = 8 * 1024;
    }
  ];
}
