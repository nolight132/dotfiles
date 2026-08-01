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
