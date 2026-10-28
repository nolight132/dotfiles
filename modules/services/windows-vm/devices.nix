{ pkgs }:

{
  # Radeon 610M inside the Ryzen 5 9600X. It sits alone in its IOMMU group and no monitor hangs off
  # it, since the host drives both screens from the RX 6800.
  igpu = {
    id = "1002:13c0";
    address = {
      bus = "0x12";
      slot = "0x00";
      function = "0x0";
    };

    # Written at boot by atlas-igpu-vbios.service from the VBIOS copy the firmware leaves in ACPI.
    rom = "/var/lib/libvirt/vbios/atlas-igpu.rom";
  };

  # HDMI audio function of the iGPU. OVMF runs the AMD GOP driver from its option ROM, without which
  # the Windows driver fails to bring the iGPU up and reports code 43.
  audio = {
    id = "1002:1640";
    address = {
      bus = "0x12";
      slot = "0x00";
      function = "0x1";
    };

    # GOP driver pulled from a Ryzen 7 9700X board, which carries the same Granite Ridge iGPU.
    rom = pkgs.fetchurl {
      name = "AMDGopDriver-granite-ridge.rom";
      url = "https://raw.githubusercontent.com/isc30/ryzen-gpu-passthrough-proxmox/9c62cb5c088097e80889ff72738f7835966dfc7d/AMDGopDriver_9700x.rom";
      hash = "sha256-Tx19YCVEvmMn9oUlLH1w1kuhvj+LFOnK7xxViavnflA=";
    };
  };

  # Enough IVSHMEM for a 3840x2160 SDR frame, so a dummy plug that comes up at 4K still fits.
  kvmfrSizeMiB = 128;
}
