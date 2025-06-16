{config, ...}: {
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

  users.users.${config.night-sky.user.name}.extraGroups = ["docker"];
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false; # Docker is a big battery drain
  };
}
