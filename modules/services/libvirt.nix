{ pkgs, ... }:

{
  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";

    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true;
      vhostUserPackages = [ pkgs.virtiofsd ];
    };
  };

  virtualisation.spiceUSBRedirection.enable = true;

  programs.virt-manager.enable = true;

  users.users."nolight".extraGroups = [ "libvirtd" ];

  systemd.services.libvirt-default-network = {
    description = "Autostart the libvirt default NAT network";
    wantedBy = [ "multi-user.target" ];
    requires = [ "libvirtd.service" ];
    after = [ "libvirtd.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      virsh --connect qemu:///system net-autostart default || true
      virsh --connect qemu:///system net-start default || true
    '';

    path = [ pkgs.libvirt ];
  };

  environment.systemPackages = with pkgs; [
    virt-viewer
    freerdp
    swtpm
    virtiofsd
  ];
}
