{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./apple-silicon-support
    ../../modules
  ];
  hardware.asahi.enable = true;
  hardware.asahi.peripheralFirmwareDirectory = ./firmware;
  networking.hostName = "macbook";
  boot.loader.efi.canTouchEfiVariables = false;

  system.stateVersion = "26.05";
}
