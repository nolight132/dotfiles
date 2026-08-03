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
  };
}
