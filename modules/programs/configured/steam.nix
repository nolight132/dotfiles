{ pkgs, ... }:

{
  programs.steam = {
    enable = true;

    package = pkgs.millennium-steam.override {
      extraPkgs = _: [
        pkgs.kdePackages.breeze
      ];
    };
  };
}
