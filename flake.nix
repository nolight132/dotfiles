{
  description = "nolight's NixOS";

  inputs = {
    nixpkgs.url = "github:nolight132/nixpkgs/personal";

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake/458cd16116c362a5e92d5db6bdc3599e4e8b1f4a";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helium = {
      url = "github:AlvaroParker/helium-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    millennium.url = "github:nolight132/millennium-nix";

    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nls.url = "github:nolight132/nls";
    wayzoomy.url = "github:nolight132/wayzoomy";
    sonora.url = "github:sonorahq/sonora/nightly";
    tokativ.url = "github:nolight132/tokativ";

    t3code = {
      url = "github:nolight132/t3code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    photocraft = {
      url = "github:nolight132/photocraft-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    delta = {
      url = "github:zed-industries/delta-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mf-cli = {
      url = "github:nolight132/mf-cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    g75-cli = {
      url = "github:nolight132/g75-cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
