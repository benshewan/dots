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

  # Preservation companion for "virtualization/libvirt" (auto-resolved by the prefix).
  flake.modules.nixos."preservation/virtualization/libvirt" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.directories = [
      # VM NVRAM, disk images and snapshots.
      "/var/lib/libvirt"
      # VM domain definitions (XML).
      "/etc/libvirt/qemu"
      # Storage authentication secrets (not /etc/libvirt: libvirt.conf is generated).
      "/etc/libvirt/secrets"
      # swtpm local CA, used to sign TPM endorsement certs for VMs.
      "/var/lib/swtpm-localca"
    ];
  };
}
