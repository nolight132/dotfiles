{ pkgs, ... }:

{
  users.users."nolight" = {
    isNormalUser = true;
    description = "nolight";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];

    shell = pkgs.fish;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHPKY8Kk+Qk7eiqeZ8wK3C0Hdly2ccNsQUiZEzmwrMlk olizkopavel@proton.me"
    ];
  };
}
