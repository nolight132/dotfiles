{ pkgs, inputs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  environment.systemPackages = with pkgs; [
    bruno

    inputs.nls.packages.${system}.default
  ];
}
