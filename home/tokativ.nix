{ inputs, ... }:

{
  imports = [ inputs.tokativ.homeModules.default ];

  services.tokativ.enable = true;

  xdg.configFile."niri/config.kdl".force = true;
}
