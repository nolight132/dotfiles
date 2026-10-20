{
  config,
  inputs,
  pkgs,
  ...
}:

{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
  };

  home.packages = [
    pkgs.sops
    pkgs.age
  ];
}
