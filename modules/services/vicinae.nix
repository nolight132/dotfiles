{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vicinae
  ];

  systemd.user.services.vicinae = {
    description = "Vicinae";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];

    enableDefaultPath = false;

    serviceConfig = {
      ExecStart = "${pkgs.vicinae}/bin/vicinae server";
      ExecStopPost = "-${pkgs.procps}/bin/pkill --full --uid nolight %t/vicinae/extension-manager.js";
      Restart = "on-failure";
      RestartSec = 1;
      KillMode = "process";
    };
  };
}
