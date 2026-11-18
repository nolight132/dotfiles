{ inputs, ... }:

{
  imports = [ inputs.nixcord.homeModules.nixcord ];

  programs.nixcord = {
    enable = true;

    discord = {
      vencord.enable = true;
      openASAR.enable = false;
    };

    # Noctalia renders rosepuccin.css into the themes directory and Vencord reloads it on every change.
    config = {
      enabledThemes = [ "rosepuccin.css" ];
      transparent = true;

      plugins = {
        fakeNitro.enable = true;
        noTrack.enable = true;
        noTypingAnimation.enable = true;
        silentTyping.enable = true;
      };
    };
  };
}
