{ pkgs, ... }:

{
  users.users."nolight" = {
    isNormalUser = true;
    description = "nolight";
    extraGroups = [ "networkmanager" "wheel" "docker" ];

    shell = pkgs.fish;
  };
}
