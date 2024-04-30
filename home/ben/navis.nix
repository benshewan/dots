{
  pkgs,
  outputs,
  ...
}: {
  imports = [
    ./generic.nix
    "${outputs.flake-path}/shared/hm/desktops/hyprland"
    "${outputs.flake-path}/themes/gruvbox/hm"
  ];

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
      name = "desc:Dell Inc. DELL P2417H KH0NG94M1NNB";
      width = 1920;
      height = 1080;
      x = -1017;
      y = -1080;
    }
    {
      name = "desc:Dell Inc. DELL P2417H KH0NG95F09UI";
      width = 1920;
      height = 1080;
      x = 903;
      y = -1080;
    }

    # Home Monitors
    {
      name = "desc:Lenovo Group Limited P24q-10 U4P00001";
      rotate = 1;
      width = 2560;
      height = 1440;
      scale = 1.25;
      x = -1152;
      y = -2048;
    }
    {
      name = "desc:Dell Inc. AW3423DWF 58082S3";
      width = 3440;
      height = 1440;
      refreshRate = 165;
      scale = 1.25;
      x = 0;
      y = -1152;
    }
  ];

  home.packages = with pkgs; [
    prismlauncher
    distrobox
    # plex-media-player
    jellyfin-media-player
    jetbrains.pycharm-professional

    # Work stuff
    teamviewer
    masterpdfeditor
    wisenet-viewer
    moonlight-qt
    inkscape

    # Messing around
    parsec-bin
    filebot
    syncthingtray
    helvum
  ];

  services.flatpak.packages = [
    # "flathub:app/io.github.Foldex.AdwSteamGtk//stable" # Doesn't seem to quite work, steam will freak out
    # "flathub:app/com.parsecgaming.parsec//stable"
    {
      appId = "com.mongodb.Compass";
      origin = "flathub";
    }
    {
      appId = "com.getpostman.Postman";
      origin = "flathub";
    }
    {
      appId = "com.github.tchx84.Flatseal";
      origin = "flathub";
    }
    # {
    #   appId = "cafe.avery.Delfin";
    #   origin = "flathub";
    # }
  ];

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
    ];
  };
}
