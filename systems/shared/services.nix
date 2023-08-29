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

      # KDE Desktop
      desktopManager.plasma5.enable = true;
      displayManager.defaultSession = "plasmawayland";
    };

    flatpak.enable = true;
    printing.enable = true;
    mongodb.enable = true;
    openssh.enable = true;

  };

  # Virtualization
  virtualisation.libvirtd.enable = true;

  # Disable certain defaults for KDE
  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
    elisa
    gwenview
    okular
    oxygen
    khelpcenter
    # konsole
  ];

  # Desktop Portal
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-kde
    ];
  };

}
