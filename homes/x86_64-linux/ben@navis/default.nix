{
  pkgs,
  lib,
  inputs,
  ...
}: {
  monitors = [
    # Internal Monitor
    {
      name = "eDP-1";
      width = 2256;
      height = 1504;
      primary = true;
      scale = 1.566667;
    }

    # Work Monitors
    {
      name = "desc:Dell Inc. DELL P2417H KH0NG95K15KL";
      width = 1920;
      height = 1080;
      x = -1017;
      y = -1080;
    }
    {
      name = "desc:Dell Inc. DELL P2417H KH0NG95F0AMI";
      width = 1920;
      height = 1080;
      x = 903;
      y = -1080;
    }

    # Home Monitors
    {
      name = "desc:Lenovo Group Limited P24q-10 U4P00001";
      # rotate = 1;
      width = 2560;
      height = 1440;
      scale = 1.25;
      y = -1152;
      x = -2048;
    }
    {
      name = "desc:Dell Inc. AW3423DWF 58082S3";
      width = 3440;
      height = 1440;
      # Some combination of my garbo dock and alpha software makes this explode my computer
      # colorProfile = "hdr";
      refreshRate = 165;
      scale = 1.25;
      x = 0;
      y = -1152;
    }
  ];

  home.packages = with pkgs; [
    prismlauncher
    distrobox
    kdePackages.kate
    mpv
    bitwarden
    bottles
    wine
    # stable.kicad
    # plex-media-player
    jellyfin-media-player
    # jetbrains.pycharm-professional
    moonlight-qt

    # Work stuff
    # teamviewer
    libreoffice-fresh
    gnome-network-displays
    # masterpdfeditor
    night-sky.wisenet-viewer
    inkscape
    krita
    obsidian

    # Messing around
    syncthingtray
    stable.handbrake

    # Audio
    qpwgraph
  ];

  programs.java = {
    enable = true;
    package = pkgs.jdk;
  };

  # services.flatpak.packages = [
  #   {
  #     appId = "com.parsecgaming.parsec";
  #     origin = "flathub";
  #   }
  #   # {
  #   #   appId = "com.getpostman.Postman";
  #   #   origin = "flathub";
  #   # }
  #   # {
  #   #   appId = "com.github.tchx84.Flatseal";
  #   #   origin = "flathub";
  #   # }
  # ];
  home.file.".config/JetBrains/WebStorm${lib.versions.majorMinor pkgs.jetbrains.webstorm.version}/prettier" = {
    source = "${pkgs.nodePackages.prettier}/lib/node_modules/prettier";
    recursive = true;
  };

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
    ];
  };
}
