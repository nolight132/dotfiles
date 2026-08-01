{ inputs, ... }:

{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.settings.warn-dirty = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    inputs.millennium.overlays.default
  ];

  programs.nix-ld.enable = true;
}
