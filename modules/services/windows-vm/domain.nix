{
  name,
  uuid,
  memoryKiB,
  currentMemoryKiB,
  cores,
  threads,
  diskPath,
  installerIso,
  virtioIso,
  sharedDir,
  sharedTag,
  ovmfCode,
  ovmfVars,
  nvramPath,
}:

let
  cdromSource = iso: if iso == null then "" else "<source file='${iso}'/>";
in
''
  <domain type='kvm'>
    <name>${name}</name>
    <uuid>${uuid}</uuid>
    <metadata>
      <libosinfo:libosinfo xmlns:libosinfo="http://libosinfo.org/xmlns/libvirt/domain/1.0">
        <libosinfo:os id="http://microsoft.com/win/11"/>
      </libosinfo:libosinfo>
    </metadata>

    <memory unit='KiB'>${toString memoryKiB}</memory>
    <currentMemory unit='KiB'>${toString currentMemoryKiB}</currentMemory>
    <memoryBacking>
      <source type='memfd'/>
      <access mode='shared'/>
    </memoryBacking>

    <vcpu placement='static'>${toString (cores * threads)}</vcpu>
    <cpu mode='host-passthrough' check='none' migratable='on'>
      <topology sockets='1' dies='1' cores='${toString cores}' threads='${toString threads}'/>
      <feature policy='require' name='topoext'/>
      <cache mode='passthrough'/>
    </cpu>

    <os>
      <type arch='x86_64' machine='q35'>hvm</type>
      <loader readonly='yes' secure='yes' type='pflash' format='raw'>${ovmfCode}</loader>
      <nvram template='${ovmfVars}' templateFormat='raw' format='raw'>${nvramPath}</nvram>
      <bootmenu enable='yes' timeout='3000'/>
    </os>

    <features>
      <acpi/>
      <apic/>
      <smm state='on'/>
      <vmport state='off'/>
      <hyperv mode='custom'>
        <relaxed state='on'/>
        <vapic state='on'/>
        <spinlocks state='on' retries='8191'/>
        <vpindex state='on'/>
        <runtime state='on'/>
        <synic state='on'/>
        <stimer state='on'>
          <direct state='on'/>
        </stimer>
        <reset state='on'/>
        <frequencies state='on'/>
        <tlbflush state='on'/>
        <ipi state='on'/>
      </hyperv>
    </features>

    <clock offset='localtime'>
      <timer name='rtc' tickpolicy='catchup'/>
      <timer name='pit' tickpolicy='delay'/>
      <timer name='hpet' present='no'/>
      <timer name='hypervclock' present='yes'/>
    </clock>

    <pm>
      <suspend-to-mem enabled='no'/>
      <suspend-to-disk enabled='no'/>
    </pm>

    <on_poweroff>destroy</on_poweroff>
    <on_reboot>restart</on_reboot>
    <on_crash>destroy</on_crash>

    <devices>
      <disk type='file' device='disk'>
        <driver name='qemu' type='qcow2' cache='none' io='native' discard='unmap'/>
        <source file='${diskPath}'/>
        <target dev='vda' bus='virtio'/>
        <boot order='2'/>
      </disk>

      <disk type='file' device='cdrom'>
        <driver name='qemu' type='raw'/>
        ${cdromSource installerIso}
        <target dev='sda' bus='sata'/>
        <readonly/>
        <boot order='1'/>
      </disk>

      <disk type='file' device='cdrom'>
        <driver name='qemu' type='raw'/>
        <source file='${virtioIso}'/>
        <target dev='sdb' bus='sata'/>
        <readonly/>
      </disk>

      <filesystem type='mount' accessmode='passthrough'>
        <driver type='virtiofs' queue='1024'/>
        <source dir='${sharedDir}'/>
        <target dir='${sharedTag}'/>
      </filesystem>

      <interface type='network'>
        <source network='default'/>
        <model type='virtio'/>
      </interface>

      <controller type='usb' model='qemu-xhci' ports='15'/>
      <controller type='sata' index='0'/>
      <controller type='virtio-serial' index='0'/>

      <tpm model='tpm-crb'>
        <backend type='emulator' version='2.0'/>
      </tpm>

      <graphics type='spice' autoport='yes'>
        <listen type='address'/>
        <image compression='off'/>
        <gl enable='no'/>
      </graphics>

      <video>
        <model type='qxl' ram='65536' vram='65536' vgamem='16384' heads='1' primary='yes'/>
      </video>

      <sound model='ich9'/>
      <audio id='1' type='spice'/>

      <input type='tablet' bus='usb'/>
      <input type='keyboard' bus='usb'/>

      <channel type='spicevmc'>
        <target type='virtio' name='com.redhat.spice.0'/>
      </channel>

      <channel type='unix'>
        <target type='virtio' name='org.qemu.guest_agent.0'/>
      </channel>

      <redirdev bus='usb' type='spicevmc'/>
      <redirdev bus='usb' type='spicevmc'/>

      <rng model='virtio'>
        <backend model='random'>/dev/urandom</backend>
      </rng>

      <memballoon model='virtio'/>
    </devices>
  </domain>
''
