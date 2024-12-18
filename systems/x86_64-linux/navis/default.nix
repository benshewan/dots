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
  night-sky.theme = "catppuccin";
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
          filebot.enable = true;
          chromium.enable = true;
          mongodb-compass.enable = true;
          kitty.enable = true;
          spotify.enable = true;
          webstorm.enable = true;
          fish.enable = true;
          kdeconnect.enable = true;
          vscode.enable = true;
        };
      };
    };
  };

  services.keylightd.enable = true;

  services.flatpak.packages = [
    {
      appId = "com.parsecgaming.parsec";
      origin = "flathub";
    }
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
  programs.steam.enable = true;
  programs.steam.extraCompatPackages = with pkgs; [
    proton-ge-bin
  ];
  programs.steam.extraPackages = with pkgs; [
    gamescope
  ];
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;

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
      orca-slicer
      btrfs-progs
      go
      gnumake
      steam-run
      adwsteamgtk
      python3
      pipx
    ]
    # Development stuff
    ++ (with pkgs; [
      (android-studio.override {forceWayland = true;})
    ]);

  programs.goldwarden = {
    enable = true;
    useSshAgent = false;
  };

  # Networking stuff

  # for lan-mouse
  networking.firewall.allowedTCPPorts = [4242];
  networking.firewall.allowedUDPPorts = [4242];

  hardware.logitech.wireless.enable = true;

  # Work
  services.mongodb = {
    enable = true;
    package = pkgs.stable.mongodb;
  };
  # networking.firewall.enable = false;

  # sops.secrets = {
  #   "orion-smb" = {};
  # };
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
