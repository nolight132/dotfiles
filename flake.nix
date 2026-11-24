{
  description = "nolight's NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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

    millennium = {
      url = "github:nolight132/millennium-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nls.url = "github:nolight132/nls";
    wayzoomy.url = "github:nolight132/wayzoomy";
    sonora.url = "github:sonorahq/sonora";
    tokativ.url = "github:nolight132/tokativ";

    t3code = {
      url = "github:nolight132/t3code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    photocraft = {
      url = "github:nolight132/photocraft-flake";
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

    # Only its vencord package is used. A bot bumps it to Vencord's main branch every hour.
    nixcord = {
      url = "github:4evy/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-packages.follows = "nixpkgs";
      inputs.nixpkgs-ci.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.nix-darwin.follows = "nix-darwin";
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

        t3 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          specialArgs = { inherit inputs; };

          modules = [ ./hosts/t3/configuration.nix ];
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
