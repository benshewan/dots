{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./global
    ../shared/desktop-enviroments/hyprland
  ];

  # gtk.theme = lib.mkForce {
  #   name = "Catppuccin-Mocha-Standard-Blue-Dark";
  #   package =
  #     pkgs.catppuccin-gtk.override
  #     {
  #       accents = ["blue"];
  #       size = "standard"; # compact
  #       tweaks = [];
  #       variant = "mocha";
  #     };
  # };

  monitors = [
    # {
    #   name = "DP-2";
    #   width = 1920;
    #   height = 1080;
    #   refreshRate = 75;
    #   workspace = "1";
    #   x = 1920;
    #   primary = true;
    # }
    # {
    #   name = "HDMI-A-2";
    #   width = 1920;
    #   height = 1080;
    #   refreshRate = 75;
    #   workspace = "2";
    #   x = 0;
    # }
    {
      name = "eDP-1";
      width = 2256;
      height = 1504;
      refreshRate = 60;
      workspace = "1";
      primary = true;
      scale = 1.25;
      x = 0;
    }
  ];
  #   dconf.settings."org.gnome.mutter" = {
  #     experimental-features = ["scale-monitor-framebuffer"];
  #   };
}
