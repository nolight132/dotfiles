{ ... }:

{
  services.xserver.xkb = {
    layout = "pl";
    variant = "";
  };
  console.keyMap = "pl2";

  services.keyd = {
    enable = true;

    keyboards.default = {
      ids = [ "*" ];

      settings = {
        main = {
          rightcontrol = "rightcontrol";
        };

        meta = {
          h = "left";
          j = "down";
          k = "up";
          l = "right";
        };
      };
    };
  };
}
