{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./hardware.nix
  ];

  # System
  networking.hostName = "navis";
  night-sky.theme = "everforest";
  specialisation = {
    hyprland.configuration.night-sky = {
      desktops.hyprland.enable = true;
      programs.npm.enable = true;
      home.extraOptions.night-sky = {
        desktops.hyprland.enable = true;
        programs = {
          firefox.enable = true;
          chromium.enable = true;
        };
      };
    };
    kde.configuration.night-sky = {
      desktops.kde.enable = true;
      programs.npm.enable = true;
      home.extraOptions.night-sky = {
        desktops.kde.enable = true;
        programs = {
          firefox.enable = true;
          chromium.enable = true;
        };
      };
    };
  };
  # # Remote management of Navis
  services.tailscale.enable = true;

  fonts.packages = with pkgs; [
    (google-fonts.override {
      fonts = ["Mulish"];
    })
  ];

  environment.systemPackages = with pkgs;
    [
      # Audio Configuration https://github.com/ceiphr/ee-framework-presets
      easyeffects
      powertop
      nm-tray
    ]
    # Development stuff
    ++ (with pkgs; [
      mongodb-tools
      android-studio
    ]);

  programs.goldwarden = {
    enable = true;
    useSshAgent = true;
  };

  # Networking stuff
  networking.extraHosts =
    (lib.concatMapStrings (x: "100.68.3.84 " + x + ".benshewan.dev\n") [
      "plex"
      "sonarr"
      "radarr"
      "prowlarr"
      "overseerr"
      "downloads"
      "auth"
      "tautulli"
      "invite"
      "portainer"
      "files"
      "admin"
      "stats"
      "nzb"
      "jellyfin"
    ])
    + ''
    '';

  # Work
  services.mongodb = {
    enable = true;
    package = pkgs.stable.mongodb;
  };
  networking.firewall.enable = false;

  # doesn't seem to work anymore on wayland
  # services.teamviewer.enable = true;

  # for wayvnc
  # networking.firewall.allowedTCPPorts = [5900];
  # networking.firewall.allowedUDPPorts = [3389];

  # MongoDB Extenal access
  # MongoDB port [27017]
  # services.mongodb.bind_ip = "127.0.0.1,192.168.0.69";
  # services.mongodb.enableAuth = false;
  # services.mongodb.initialRootPassword = "Coldsteel@22";
}
