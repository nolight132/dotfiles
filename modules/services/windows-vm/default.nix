{ lib, pkgs, ... }:

let
  user = "nolight";
  home = "/home/${user}";

  vmName = "atlas";
  vmUuid = "6e5710a7-846f-486c-a258-a62f1c75b2d9";
  vmMac = "52:54:00:97:74:d7";
  cores = 4;
  threads = 2;
  maxMemoryGiB = 16;
  bootMemoryGiB = 8;
  diskGiB = 128;

  # ryzen 9600x: sibling of core n is thread n+6
  hostCores = 6;
  hostReservedCores = 2;

  reservedCores = lib.range 0 (hostReservedCores - 1);
  guestCores = lib.range hostReservedCores (hostReservedCores + cores - 1);

  siblingOf = core: thread: core + thread * hostCores;

  vcpuPins = lib.concatLists (
    lib.imap0 (
      core: hostCore:
      lib.genList (thread: {
        vcpu = core * threads + thread;
        cpu = siblingOf hostCore thread;
      }) threads
    ) guestCores
  );

  reservedCpuset = lib.concatMapStringsSep "," toString (
    lib.concatMap (thread: map (core: siblingOf core thread) reservedCores) (lib.range 0 (threads - 1))
  );

  imageDir = "/var/lib/libvirt/images";
  diskPath = "${imageDir}/${vmName}.qcow2";
  nvramPath = "/var/lib/libvirt/qemu/nvram/${vmName}_VARS.fd";

  isoDir = "${home}/VMs/iso";
  installerIso = "${isoDir}/windows-11.iso";

  sharedDir = "${home}/Documents/VM_Shared";
  vmWorkspace = "windows";
  vmScalePercent = 125;

  sharedTag = "VMShared";
  projectsDir = "${home}/Projects";
  projectsMount = "${sharedDir}/Projects";

  ovmf = pkgs.OVMFFull.fd;

  virtioIso =
    pkgs.runCommand "virtio-win.iso"
      {
        nativeBuildInputs = [ pkgs.xorriso ];
      }
      ''
        xorrisofs -J -r -V virtio-win -o "$out" ${pkgs.virtio-win}
      '';

  vmLauncher = pkgs.writeShellApplication {
    name = "winvm";

    runtimeInputs = [
      pkgs.libvirt
      pkgs.freerdp
      pkgs.jq
      pkgs.niri
      pkgs.gnugrep
      pkgs.coreutils
      pkgs.bash
    ];

    text = ''
      uri=qemu:///system
      domain=${vmName}
      mac=${vmMac}
      workspace=${vmWorkspace}
      guest_user=${user}
      scale=${toString vmScalePercent}

      if [ "$(virsh -c "$uri" domstate "$domain")" != "running" ]; then
        echo "winvm: starting $domain"
        virsh -c "$uri" start "$domain"
      fi

      lease_ip() {
        virsh -q -c "$uri" net-dhcp-leases default \
          | grep -F "$mac" \
          | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}/' \
          | tr -d '/' \
          | head -1
      }

      ip=""
      for _ in $(seq 90); do
        candidate=$(lease_ip)
        if [ -n "$candidate" ] \
          && timeout 1 bash -c "cat < /dev/null > /dev/tcp/$candidate/3389" 2>/dev/null; then
          ip=$candidate
          break
        fi
        sleep 1
      done

      if [ -z "$ip" ]; then
        echo "winvm: $domain never opened rdp on 3389" >&2
        exit 1
      fi

      workspaces=$(niri msg -j workspaces)
      output=$(jq -r --arg w "$workspace" \
        'first(.[] | select(.name == $w) | .output) // empty' <<< "$workspaces")

      if [ -z "$output" ]; then
        output=$(jq -r 'first(.[] | select(.is_focused) | .output) // empty' <<< "$workspaces")
      fi

      geometry=()
      if [ -n "$output" ]; then
        read -r width height < <(
          niri msg -j outputs \
            | jq -r --arg o "$output" '.[$o] | .modes[.current_mode] | "\(.width) \(.height)"'
        )
        geometry=("/w:$width" "/h:$height")
      else
        echo "winvm: no niri output found, letting the client pick a size" >&2
      fi

      exec sdl-freerdp \
        "/v:$ip" \
        "/u:$guest_user" \
        /sec:tls \
        /cert:ignore \
        /f \
        "''${geometry[@]}" \
        "/scale-desktop:$scale" \
        /gfx:AVC444 \
        /clipboard \
        /sound \
        /network:lan
    '';
  };
  domainXml = pkgs.writeText "${vmName}.xml" (
    import ./domain.nix {
      name = vmName;
      uuid = vmUuid;
      mac = vmMac;
      memoryKiB = maxMemoryGiB * 1024 * 1024;
      currentMemoryKiB = bootMemoryGiB * 1024 * 1024;
      ovmfCode = "${ovmf}/FV/OVMF_CODE.ms.fd";
      ovmfVars = "${ovmf}/FV/OVMF_VARS.ms.fd";
      installerIso = null;

      inherit
        cores
        threads
        vcpuPins
        reservedCpuset
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
  assertions = [
    {
      assertion = hostReservedCores + cores <= hostCores;
      message = "windows-vm: ${toString cores} guest cores plus ${toString hostReservedCores} reserved cores exceed the ${toString hostCores} host cores";
    }
  ];

  environment.systemPackages = [ vmLauncher ];

  systemd.tmpfiles.rules = [
    "d ${home}/VMs 0755 ${user} users -"
    "d ${isoDir} 0755 ${user} users -"
    "d ${sharedDir} 0755 ${user} users -"
    "d ${projectsDir} 0755 ${user} users -"
    "d ${projectsMount} 0755 ${user} users -"
  ];

  systemd.mounts = [
    {
      description = "Expose ${projectsDir} inside the ${vmName} virtiofs share";
      what = projectsDir;
      where = projectsMount;
      type = "none";
      options = "bind";

      wantedBy = [ "multi-user.target" ];
      requires = [ "systemd-tmpfiles-setup.service" ];
      after = [ "systemd-tmpfiles-setup.service" ];
    }
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
