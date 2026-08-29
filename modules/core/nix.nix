{ inputs, ... }:

{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    extra-substituters = [
      "https://nixpkgs-nolight.cachix.org"
    ];

    extra-trusted-public-keys = [
      "nixpkgs-nolight.cachix.org-1:SBWHxL9ZOy1jY9hGvTJPEifa/v0Fm2Y+qiMrqb8QdKM="
    ];
  };

  nix.settings.warn-dirty = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    inputs.millennium.overlays.default
  ];

  programs.nix-ld.enable = true;
}
