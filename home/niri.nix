{ lib, ... }:

let
  kdlFiles = builtins.attrNames (
    lib.filterAttrs (n: t: t == "regular" && lib.hasSuffix ".kdl" n) (builtins.readDir ./niri)
  );
in
{
  xdg.configFile =
    (lib.listToAttrs (map (n: lib.nameValuePair "niri/${n}" { source = ./niri + "/${n}"; }) kdlFiles))
    // {
      "niri/scripts/toggle-telegram-screencast.sh" = {
        source = ./niri/scripts/toggle-telegram-screencast.sh;
        executable = true;
      };
    };
}
