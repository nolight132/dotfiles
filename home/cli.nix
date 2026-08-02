{ pkgs, inputs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  programs.zoxide.enable = true;
  programs.carapace.enable = true;

  home.sessionVariables.CARAPACE_LENIENT = "1";

  home.packages = with pkgs; [
    fzf
    bat

    inputs.nls.packages.${system}.default
  ];
}
