{ pkgs, ... }:

{
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.pipewire.extraConfig.pipewire."92-low-latency" = {
    "context.properties" = {
      "default.clock.rate" = 48000;
      "default.clock.quantum" = 128;
      "default.clock.min-quantum" = 96;
      "default.clock.max-quantum" = 1024;
    };
  };

  services.pipewire.wireplumber.extraConfig."51-disable-brio-audio" = {
    "monitor.alsa.rules" = [
      {
        matches = [
          {
            "node.name" = "~alsa_.*Brio.*";
          }
        ];

        actions = {
          update-props = {
            "node.disabled" = true;
          };
        };
      }
    ];
  };

  environment.systemPackages = with pkgs; [
    pulseaudio # pactl and friends
    pavucontrol
    easyeffects
    playerctl
    qpwgraph
  ];
}
