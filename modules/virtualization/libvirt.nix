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

  # Preservation companion for "virtualization/libvirt".
  # `config.flake.lib.resolve` imports it (together with the base preservation
  # module) automatically because of the "preservation/" prefix. Upstream
  # ignores `preserveAt` until `preservation.enable` is true.
  flake.modules.nixos."preservation/virtualization/libvirt" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.directories = [
      # NVRAM, disk images, snapshots and libvirt's own state.
      "/var/lib/libvirt"

      # VM domain definitions (XML) and disk/volume authentication secrets.
      # /etc/libvirt/libvirt.conf itself is managed by the NixOS module and must
      # not be mounted over. Without the secrets, VMs with encrypted storage
      # fail to start.
      "/etc/libvirt/qemu"
      "/etc/libvirt/secrets"
    ];
  };
}
