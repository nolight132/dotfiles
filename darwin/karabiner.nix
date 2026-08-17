{ pkgs, lib, ... }:

let
  profile = "nolight";

  karabinerCli = "/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli";

  arrows = {
    h = "left_arrow";
    j = "down_arrow";
    k = "up_arrow";
    l = "right_arrow";
  };

  manipulators = lib.mapAttrsToList (key: arrow: {
    type = "basic";
    from = {
      key_code = key;
      modifiers = {
        mandatory = [ "control" ];
        optional = [ "any" ];
      };
    };
    to = [ { key_code = arrow; } ];
  }) arrows;

  karabinerJson = pkgs.writeText "karabiner.json" (
    builtins.toJSON {
      global = {
        show_in_menu_bar = false;
        check_for_updates_on_startup = false;
      };

      profiles = [
        {
          name = profile;
          selected = true;
          virtual_hid_keyboard.keyboard_type_v2 = "iso";
          devices = [ ];
          fn_function_keys = [ ];
          simple_modifications = [ ];
          complex_modifications = {
            parameters = { };
            rules = [
              {
                description = "Control + hjkl to arrow keys";
                inherit manipulators;
              }
            ];
          };
        }
      ];
    }
  );
in
{
  home-manager.users."nolight" =
    { lib, ... }:
    {
      home.activation.karabinerConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run mkdir -p "$HOME/.config/karabiner"
        run install -m 644 ${karabinerJson} "$HOME/.config/karabiner/karabiner.json"

        if [ -x ${lib.escapeShellArg karabinerCli} ]; then
          run ${lib.escapeShellArg karabinerCli} --select-profile ${lib.escapeShellArg profile} || true
        fi
      '';
    };
}
