{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules
  ];

  networking.hostName = "nixos";

  system.stateVersion = "26.05";
}
