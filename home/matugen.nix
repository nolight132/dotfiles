{
  config,
  lib,
  pkgs,
  ...
}:

let
  openrgbScript = "${config.xdg.configHome}/OpenRGB/matugen.sh";
in
{
  xdg.configFile = {
    "matugen/config.toml".source = ./matugen/config.toml;
    "matugen/templates".source = ./matugen/templates;
  };

  # Applies the last matugen colour to the RGB devices at login. It retries until the OpenRGB
  # server has finished detecting devices, because the script fails while either device is missing.
  systemd.user.services.openrgb-matugen = {
    Unit = {
      Description = "Apply the matugen colour to OpenRGB devices";
      ConditionPathExists = openrgbScript;
      StartLimitIntervalSec = 120;
      StartLimitBurst = 30;
    };

    Service = {
      Type = "oneshot";
      Environment = "PATH=${
        lib.makeBinPath [
          pkgs.gawk
          pkgs.openrgb
        ]
      }";
      ExecStart = "${pkgs.runtimeShell} ${openrgbScript}";
      Restart = "on-failure";
      RestartSec = 3;
    };

    Install.WantedBy = [ "default.target" ];
  };
}
