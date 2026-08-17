{ pkgs, lib, ... }:

let
  yabai = "${pkgs.yabai}/bin/yabai";

  workspaces = [
    1
    2
    3
    4
  ];

  focus = lib.concatMapStringsSep "\n" (n: "cmd - ${toString n} : ${yabai} -m space --focus ${toString n}") workspaces;

  move = lib.concatMapStringsSep "\n" (
    n: "cmd + shift - ${toString n} : ${yabai} -m window --space ${toString n}"
  ) workspaces;
in
{
  services.skhd = {
    enable = true;

    skhdConfig = ''
      ${focus}

      ${move}
    '';
  };
}
