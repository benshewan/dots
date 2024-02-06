{
  pkgs,
  lib,
  outputs,
  ...
}: {
  services = {
    xserver = {
      enable = true;
      xkb.layout = "us";
      xkb.variant = "";
      excludePackages = [pkgs.xterm];
    };

    flatpak.enable = true;
    openssh.enable = true;
    upower = {
      enable = true;
      percentageCritical = 15;
      criticalPowerAction = "Hibernate";
    };

    printing.enable = true;
    printing.drivers = [pkgs.foomatic-db-ppds-withNonfreeDb];
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };

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
