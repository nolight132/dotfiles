{ pkgs, inputs, ... }:

{
  imports = [
    inputs.noctalia-greeter.nixosModules.default
  ];

  programs.noctalia-greeter = {
    enable = true;

    settings = {
      session.default = "Niri";
      user.default = "nolight";

      cursor = {
        theme = "Breeze_Light";
        size = 24;
        path = "${pkgs.kdePackages.breeze}/share/icons";
      };

      keyboard.layout = "pl";
    };
  };
}
