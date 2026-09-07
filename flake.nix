{
  description = "nolight's NixOS";

  inputs = {
    nixpkgs.url = "github:nolight132/nixpkgs/personal";

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helium = {
      url = "github:AlvaroParker/helium-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    millennium.url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";

    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nls.url = "github:nolight132/nls";
    wayzoomy.url = "github:nolight132/wayzoomy";
    sonora.url = "github:nolight132/sonora";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      ...
    }:
    {
      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          specialArgs = { inherit inputs; };

          modules = [
            inputs.determinate.nixosModules.default
            ./hosts/desktop/configuration.nix
          ];
        };
      };

      darwinConfigurations = {
        macbook-air = inputs.nix-darwin.lib.darwinSystem {
          specialArgs = { inherit inputs; };

          modules = [
            ./hosts/macbook-air/configuration.nix
          ];
        };
      };
    };
}
