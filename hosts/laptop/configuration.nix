{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules
  ];
  hardware.asahi.enable = true;
  hardware.asahi.peripheralFirmwareDirectory = ./firmware;
  networking.hostName = "macbook";
  boot.loader.efi.canTouchEfiVariables = false;

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 8 * 1024;
    }
  ];

  system.stateVersion = "26.05";
}
