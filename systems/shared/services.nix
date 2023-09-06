{ lib, pkgs, username, ... }:
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
    openssh.enable = true;
    upower.enable = true;
  };

  # services.greetd = {
  #   enable = true;
  #   # settings.default_session = {
  #   #   command = "cage -s -- regreet";
  #   #   user = "greeter";
  #   # };
  # };
  # programs.regreet.enable = true;


  # Virtualization
  virtualisation.libvirtd.enable = true;
}
