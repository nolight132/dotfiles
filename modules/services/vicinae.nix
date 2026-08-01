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
