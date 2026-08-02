{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vicinae
  ];

  systemd.user.services.vicinae = {
    description = "Vicinae";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];

    # systemd's Environment=PATH= replaces the inherited value rather than
    # extending it, so without this the launcher only sees the coreutils/
    # findutils/grep/sed/systemd defaults and cannot resolve desktop entries
    # like `Exec=zen`. Live profile paths, not config.system.path, so newly
    # installed apps are picked up without a restart.
    path = [
      "/run/wrappers"
      "/etc/profiles/per-user/nolight"
      "/run/current-system/sw"
    ];

    serviceConfig = {
      ExecStart = "${pkgs.vicinae}/bin/vicinae server";
      Restart = "on-failure";
      RestartSec = 1;
    };

    restartTriggers = [
      config.system.path
    ];
  };
}
