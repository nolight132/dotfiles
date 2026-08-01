{ pkgs, inputs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  programs.fish.enable = true;

  environment.shellAliases = {
    ls = "nls";
    cat = "bat";
  };

  environment.systemPackages = with pkgs; [
    starship
    zoxide
    atuin
    fzf
    bat

    inputs.nls.packages.${system}.default
  ];
}
