{pkgs, ...}: {
  programs.xwayland.enable = true; # Enable XWayland support
  services = {
    xserver = {
      enable = true;
      xkb.layout = "us";
      xkb.variant = "";
      excludePackages = [pkgs.xterm];
    };
  };
}
