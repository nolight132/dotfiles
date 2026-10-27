{ config, ... }:

let
  secret = config.sops.placeholder;
in
{
  sops.secrets = {
    "ssh/mac/hostname" = { };
    "ssh/vps/hostname" = { };
    "ssh/vps/port" = { };
  };

  sops.templates."ssh-hosts".content = ''
    Host mac
        HostName ${secret."ssh/mac/hostname"}

    Host vps
        HostName ${secret."ssh/vps/hostname"}
        Port ${secret."ssh/vps/port"}
  '';

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    includes = [ config.sops.templates."ssh-hosts".path ];

    settings = {
      mac.user = "nolight";
      vps.user = "nolight";
    };
  };
}
