{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./hardware.nix
    ./networking.nix
  ];

  # System
  networking.hostName = "navis";
  night-sky.theme = "gruvbox";
  night-sky = {
    desktops.hyprland.enable = true;
    programs.npm.enable = true;
    programs.vivaldi.enable = true;
    home.extraOptions = {
      stylix.targets.qt.enable = true;
      night-sky = {
        desktops.hyprland.enable = true;
        programs = {
          firefox.enable = true;
          thunderbird.enable = true;
          filebot.enable = true;
          chromium.enable = true;
          mongodb-compass.enable = true;
          foot.enable = true;
          kitty.enable = true;
          spotify.enable = true;
          # webstorm.enable = true;
          fish.enable = true;
          kdeconnect.enable = true;
          vscode.enable = true;
        };
      };
    };
  };

  services.keylightd.enable = true;

  services.flatpak.packages = [
    # {
    #   appId = "com.parsecgaming.parsec";
    #   origin = "flathub";
    # }
    {
      appId = "org.jdownloader.JDownloader";
      origin = "flathub";
    }
    # {
    #   appId = "com.getpostman.Postman";
    #   origin = "flathub";
    # }
    # {
    #   appId = "com.github.tchx84.Flatseal";
    #   origin = "flathub";
    # }
  ];

  # Remote management of Navis
  services.tailscale.enable = true;

  fonts.packages = with pkgs; [
    (google-fonts.override {
      fonts = ["Mulish"];
    })
  ];

  environment.systemPackages = with pkgs;
    [
      # Audio Configuration https://github.com/ceiphr/ee-framework-presets
      # easyeffects
      powertop
      nm-tray
      solaar
      # lan-mouse
      # orca-slicer
      parsec-bin
      python3
    ]
    # Development stuff
    ++ (with pkgs; [
      (android-studio.override {forceWayland = true;})
    ]);

  hardware.logitech.wireless.enable = true;

  programs.goldwarden = {
    enable = true;
    useSshAgent = false;
  };

  # Work
  services.mongodb = {
    enable = true;
    package = pkgs.stable.mongodb;
  };

  # For expo
  networking.firewall.allowedTCPPorts = [8081 7100];

  # for wayvnc
  # networking.firewall.allowedTCPPorts = [5900];
  # networking.firewall.allowedUDPPorts = [3389];

  # MongoDB Extenal access
  # MongoDB port [27017]
  # services.mongodb.bind_ip = "127.0.0.1,192.168.0.69";
  # services.mongodb.enableAuth = false;
  # services.mongodb.initialRootPassword = "Coldsteel@22";
}
