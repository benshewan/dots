{ lib, pkgs, ... }:
{
  services = {
    xserver = {
      enable = true;
      layout = "us";
      xkbVariant = "";
      excludePackages = [ pkgs.xterm ];

      # Login Manager
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
    };

    flatpak.enable = true;
    printing.enable = true;
    mongodb.enable = true;
    openssh.enable = true;

  };

  # Virtualization
  virtualisation.libvirtd.enable = true;
}
