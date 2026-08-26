{ ... }:

{
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    plymouth.enable = false;
    consoleLogLevel = 3;
    kernelParams = [
      "quiet"
      "rd.systemd.show_status=auto"
      "rd.udev.log_level=3"

      "systemd.show_status=auto"
      "udev.log_level=3"
    ];
    loader.timeout = 1;
    initrd.kernelModules = [ "amdgpu" ];
  };

  systemd.services.NetworkManager-wait-online.enable = false;
}
