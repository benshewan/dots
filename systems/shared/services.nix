{ pkgs, ... }:
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
  virtualisation.libvirtd.enable = true;
}
