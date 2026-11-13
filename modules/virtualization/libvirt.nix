{config, ...}: {
  flake.modules.nixos."virtualization/libvirt" = {pkgs, ...}: {
    # Libvirt/QEMU
    virtualisation.spiceUSBRedirection.enable = true;

    users.groups.plugdev = {};

    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
      };
    };

    programs.virt-manager.enable = true;

    users.users.${config.flake.meta.user.username}.extraGroups = ["libvirtd" "plugdev"];

    environment.systemPackages = with pkgs; [
      # QEMU/KVM tools
      virt-viewer
      spice
      spice-gtk
      spice-protocol
      virtio-win
      win-spice
      swtpm
      OVMFFull
      usbredir
    ];

    networking.firewall.trustedInterfaces = ["virbr0"];
  };
  flake.modules.homeManager."virtualization/libvirt" = {pkgs, ...}: {
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = ["qemu:///system"];
        uris = ["qemu:///system"];
      };
    };
  };

  # Preservation companion for "virtualization/libvirt" (auto-resolved by the
  # prefix).
  # VERIFIED empirically (libvirt 11.x on nixpkgs 26.11, defined test
  # domain/network/pool/secret on caelum): EVERYTHING libvirt persists now
  # lives under /var/lib/libvirt — domain XMLs (qemu/<name>.xml),
  # networks (qemu/networks/), storage pools (storage/), secrets +
  # secrets-encryption-key (secrets/), nwfilter rules, hooks/, and the
  # runtime copies qemu.conf/network.conf; plus nvram/ram/varstore (UEFI),
  # save/, snapshot/, checkpoint/, dump/ and per-VM swtpm state (swtpm/).
  # The former /etc/libvirt/qemu and /etc/libvirt/secrets entries are
  # legacy: those paths stay EMPTY on this libvirt version (and don't even
  # exist on hosts that never had them). swtpm-localca keeps its own
  # top-level dir below.
  flake.modules.nixos."preservation/virtualization/libvirt" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.directories = [
      "/var/lib/libvirt"
      # swtpm local CA, used to sign TPM endorsement certs for VMs.
      "/var/lib/swtpm-localca"
    ];
  };
}
