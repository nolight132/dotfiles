{ lib, pkgs, ... }:

let
  devices = import ./devices.nix { inherit pkgs; };

  vendorId = id: builtins.elemAt (lib.splitString ":" id) 0;
  deviceId = id: builtins.elemAt (lib.splitString ":" id) 1;

  # Copies the VBIOS of one PCI device out of an ACPI VFCT table. The table is a 76 byte header
  # followed by images, each behind a 28 byte header that carries the vendor id at 12, the device
  # id at 14 and the image length at 24. Exits non-zero when no image matches.
  extractVbios = pkgs.writeShellApplication {
    name = "extract-vbios";

    runtimeInputs = [ pkgs.coreutils ];

    text = ''
      vfct=$1
      vendor=$((16#$2))
      device=$((16#$3))
      out=$4

      u16() { od -An -tu2 -j "$1" -N2 "$vfct" | tr -d ' '; }
      u32() { od -An -tu4 -j "$1" -N4 "$vfct" | tr -d ' '; }

      length=$(u32 4)
      offset=$(u32 52)

      while [ "$offset" -lt "$length" ]; do
        size=$(u32 $((offset + 24)))

        if [ "$(u16 $((offset + 12)))" = "$vendor" ] && [ "$(u16 $((offset + 14)))" = "$device" ]; then
          mkdir -p "$(dirname "$out")"
          dd if="$vfct" of="$out.tmp" bs=4096 status=none \
            iflag=skip_bytes,count_bytes skip=$((offset + 28)) count="$size"

          if [ "$(od -An -tx1 -N2 "$out.tmp" | tr -d ' ')" != 55aa ]; then
            echo "extract-vbios: image for $2:$3 lacks the 55aa option rom signature" >&2
            rm -f "$out.tmp"
            exit 1
          fi

          mv "$out.tmp" "$out"
          exit 0
        fi

        offset=$((offset + 28 + size))
      done

      echo "extract-vbios: $vfct has no image for $2:$3" >&2
      exit 1
    '';
  };
in
{
  boot = {
    kernelParams = [
      "iommu=pt"
      "vfio-pci.ids=${devices.igpu.id},${devices.audio.id}"
    ];

    initrd.kernelModules = [
      "vfio_pci"
      "vfio"
      "vfio_iommu_type1"
    ];

    # amdgpu and snd_hda_intel would claim the iGPU first if udev loaded them before vfio-pci.
    extraModprobeConfig = ''
      softdep amdgpu pre: vfio-pci
      softdep snd_hda_intel pre: vfio-pci
    '';
  };

  systemd.services.atlas-igpu-vbios = {
    description = "Extract the iGPU VBIOS for the atlas guest from the ACPI VFCT table";
    wantedBy = [ "libvirtd.service" ];
    before = [ "libvirtd.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = lib.escapeShellArgs [
        (lib.getExe extractVbios)
        "/sys/firmware/acpi/tables/VFCT"
        (vendorId devices.igpu.id)
        (deviceId devices.igpu.id)
        devices.igpu.rom
      ];
    };
  };
}
