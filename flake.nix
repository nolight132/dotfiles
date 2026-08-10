{
  description = "nolight's NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Temp until kernel is fixed
    kernel-nixpkgs.url = "github:NixOS/nixpkgs/148bab9";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    millennium.url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";

    nls.url = "github:nolight132/nls";
    wayzoomy.url = "github:nolight132/wayzoomy";
    sonora.url = "github:nolight132/sonora";
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    {
      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          specialArgs = { inherit inputs; };

          modules = [
            ./hosts/desktop/configuration.nix
          ];
        };
        laptop = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { inherit inputs; };

          modules = [
            ./hosts/laptop/configuration.nix
          ];
        };
      };
    };
}
