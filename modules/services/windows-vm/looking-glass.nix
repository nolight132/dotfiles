{ config, pkgs, ... }:

let
  devices = import ./devices.nix { inherit pkgs; };
in
{
  boot = {
    extraModulePackages = [ config.boot.kernelPackages.kvmfr ];

    # Loaded at boot because QEMU creates /dev/kvmfr0 as a plain file if it starts the guest first.
    kernelModules = [ "kvmfr" ];

    extraModprobeConfig = ''
      options kvmfr static_size_mb=${toString devices.kvmfrSizeMiB}
    '';
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="kvmfr", OWNER="nolight", GROUP="kvm", MODE="0660"
  '';

  virtualisation.libvirtd.qemu.verbatimConfig = ''
    cgroup_device_acl = [
      "/dev/null", "/dev/full", "/dev/zero",
      "/dev/random", "/dev/urandom",
      "/dev/ptmx", "/dev/kvm", "/dev/userfaultfd",
      "/dev/kvmfr0"
    ]
  '';
}
