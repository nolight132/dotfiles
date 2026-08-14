{
  description = "nolight's NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/1e544d5f3944e555dd7919258882562e616407a8";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    asahi-nixpkgs.url = "github:NixOS/nixpkgs/b7c2ada94fe99c15b0dbcf4d11fd7850b957a436";
    apple-silicon.url = "github:nix-community/nixos-apple-silicon/3d2325a31f37221e276f721fabac363a65d0cf7d";

    millennium.url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";

    nls.url = "github:nolight132/nls";
    wayzoomy.url = "github:nolight132/wayzoomy";
    sonora.url = "github:nolight132/sonora";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      apple-silicon,
      asahi-nixpkgs,
      ...
    }:
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
            apple-silicon.nixosModules.apple-silicon-support
            {
              hardware.asahi.pkgs = nixpkgs.lib.mkForce (
                import asahi-nixpkgs {
                  system = "aarch64-linux";

                  overlays = [
                    apple-silicon.overlays.default
                  ];
                }
              );
            }

            ./hosts/laptop/configuration.nix
          ];
        };
      };
    };
}
