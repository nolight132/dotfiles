{ pkgs, ... }:

let
  user = "nolight";
  home = "/home/${user}";

  vmName = "atlas";
  cores = 4;
  threads = 2;
  maxMemoryGiB = 16;
  bootMemoryGiB = 8;
  diskGiB = 128;

  imageDir = "/var/lib/libvirt/images";
  diskPath = "${imageDir}/${vmName}.qcow2";
  nvramPath = "/var/lib/libvirt/qemu/nvram/${vmName}_VARS.fd";

  isoDir = "${home}/VMs/iso";
  installerIso = "${isoDir}/windows-11.iso";

  sharedDir = "${home}/Documents/VM_Shared";
  sharedTag = "VMShared";

  ovmf = pkgs.OVMFFull.fd;

  virtioIso =
    pkgs.runCommand "virtio-win.iso"
      {
        nativeBuildInputs = [ pkgs.xorriso ];
      }
      ''
        xorrisofs -J -r -V virtio-win -o "$out" ${pkgs.virtio-win}
      '';

  domainXml = pkgs.writeText "${vmName}.xml" (
    import ./domain.nix {
      name = vmName;
      memoryKiB = maxMemoryGiB * 1024 * 1024;
      currentMemoryKiB = bootMemoryGiB * 1024 * 1024;
      ovmfCode = "${ovmf}/FV/OVMF_CODE.ms.fd";
      ovmfVars = "${ovmf}/FV/OVMF_VARS.ms.fd";
      installerIso = null;

      inherit
        cores
        threads
        diskPath
        nvramPath
        virtioIso
        sharedDir
        sharedTag
        ;
    }
  );
in
{
  systemd.tmpfiles.rules = [
    "d ${home}/VMs 0755 ${user} users -"
    "d ${isoDir} 0755 ${user} users -"
    "d ${sharedDir} 0755 ${user} users -"
  ];

  systemd.services."libvirt-vm-${vmName}" = {
    description = "Define the ${vmName} Windows guest";
    wantedBy = [ "multi-user.target" ];
    requires = [ "libvirtd.service" ];

    after = [
      "libvirtd.service"
      "libvirt-default-network.service"
      "systemd-tmpfiles-setup.service"
    ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    path = [
      pkgs.libvirt
      pkgs.qemu_kvm
      pkgs.e2fsprogs
    ];

    script = ''
      mkdir -p ${imageDir}
      chattr +C ${imageDir} 2>/dev/null || true

      fresh=0
      if [ ! -f ${diskPath} ]; then
        qemu-img create -f qcow2 ${diskPath} ${toString diskGiB}G
        fresh=1
      fi

      virsh --connect qemu:///system define ${domainXml}

      if [ "$fresh" = 1 ] && [ -f ${installerIso} ]; then
        virsh --connect qemu:///system change-media \
          ${vmName} sda ${installerIso} --update --config
      fi
    '';
  };
}
