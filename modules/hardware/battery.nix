{ config, lib, ... }:

{
  services.upower.enable = lib.mkIf (config.networking.hostName == "macbook") true;
}
