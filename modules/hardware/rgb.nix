{ inputs, pkgs, ... }:

{
  imports = [ inputs.g75-cli.nixosModules.default ];

  services.hardware.openrgb.enable = true;
  hardware.mchose-g75.enable = true;

  environment.systemPackages = with pkgs; [
    openrgb
  ];
}
