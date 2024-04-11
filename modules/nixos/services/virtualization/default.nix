{outputs, ...}: {
  # Virtualization
  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
  };
  virtualisation.spiceUSBRedirection.enable = true;
  # systemd.services.libvirtd-config.script = lib.mkAfter ''
  #   mkdir -p  /var/lib/libvirt/qemu/networks/autostart
  #   cp ${pkgs.libvirt}/var/lib/libvirt/qemu/networks/autostart/default.xml /var/lib/libvirt/qemu/networks/autostart/default.xml
  # '';

  users.users.${outputs.username}.extraGroups = ["podman"];
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };
}
