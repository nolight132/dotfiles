{ pkgs, ... }:

{
  users.users."nolight" = {
    isNormalUser = true;
    description = "nolight";
    extraGroups = [ "networkmanager" "wheel" ];

    shell = pkgs.fish;
    packages = with pkgs; [];
  };
}
