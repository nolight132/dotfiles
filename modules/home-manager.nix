{ inputs, ... }:

{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    backupFileExtension = "hm-bak";

    extraSpecialArgs = { inherit inputs; };

    users."nolight" = {
      imports = import ../lib/importAll.nix ../home;

      home.stateVersion = "26.05";
    };
  };
}
