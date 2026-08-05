{ config, lib, ... }:

let
  mutableKdl = "screencast-privacy.kdl";
  kdlFiles = builtins.attrNames (
    lib.filterAttrs (n: t: t == "regular" && lib.hasSuffix ".kdl" n && n != mutableKdl) (
      builtins.readDir ./niri
    )
  );
  ruleFile = "${config.xdg.configHome}/niri/${mutableKdl}";
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

  # runtime mutable
  home.activation.niriScreencastPrivacy = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    if [ -L "${ruleFile}" ]; then
      run rm -f "${ruleFile}"
    fi
    if [ ! -e "${ruleFile}" ]; then
      run install -Dm644 ${./niri + "/${mutableKdl}"} "${ruleFile}"
    fi
  '';
}
