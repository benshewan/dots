{ pkgs, lib, ... }:
{
  services = {
    xserver = {
      enable = true;
      layout = "us";
      xkbVariant = "";
      excludePackages = [ pkgs.xterm ];
    };

    flatpak.enable = true;
    printing.enable = true;
    openssh.enable = true;
    upower.enable = true;
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
}
