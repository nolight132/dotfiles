{ lib, ... }:

{
  programs.fastfetch = {
    enable = true;

    settings = lib.recursiveUpdate (builtins.fromJSON (builtins.readFile ./fastfetch/config.json)) {
      logo.source = ./fastfetch/nix-snowflake.png;
    };
  };
}
