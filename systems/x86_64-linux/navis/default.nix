{pkgs, ...}: {
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
    home.extraOptions = {
      stylix.targets.kvantum.enable = true;
      night-sky = {
        desktops.hyprland.enable = true;
        programs = {
          firefox.enable = true;
          zen.enable = true;
          thunderbird.enable = true;
          filebot.enable = true;
          chromium.enable = true;
          mongodb-compass.enable = true;
          foot.enable = true;
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

  # boot.supportedFilesystems = {
  #   zfs = true;
  # };
  # boot.zfs.forceImportRoot = false;
  # networking.hostId = "355e7f23";

  environment.systemPackages = with pkgs;
    [
      # Audio Configuration https://github.com/ceiphr/ee-framework-presets
      # easyeffects
      powertop
      piper
      nm-tray
      discord
      # lan-mouse
      # orca-slicer
      night-sky.audio-share
      parsec-bin
      jetbrains-toolbox
      python3

      (proxmark3.override {withGeneric = true;})
    ]
    # Development stuff
    ++ (with pkgs; [
      (android-studio.override {forceWayland = true;})
    ]);

  hardware.logitech.wireless = {
    enable = true;
    enableGraphical = true;
  };

  # hardware.openrazer.enable = true;
  # hardware.openrazer.users = [config.night-sky.user.name];

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
  networking.firewall.allowedTCPPorts = [
    8081
    7100 # Development
    65530 # audio-share
  ];
  networking.firewall.allowedUDPPorts = [65530];

  services.pipewire.extraConfig.pipewire."audio-share-sink" = {
    "context.objects" = [
      {
        factory = "adapter";
        args = {
          "factory.name" = "support.null-audio-sink";
          "node.name" = "Audio Share Sink";
          "media.class" = "Audio/Sink";
          "object.linger" = true;
          "audio.position" = ["FL" "FR"];
          "priority.session" = 1009;
          "priority.driver" = 1009;
          "monitor.channel-volumes" = true;
          "monitor.passthrough" = true;
        };
      }
    ];
  };

  # MongoDB Extenal access
  # MongoDB port [27017]
  # services.mongodb.bind_ip = "127.0.0.1,192.168.0.69";
  # services.mongodb.enableAuth = false;
  # services.mongodb.initialRootPassword = "Coldsteel@22";
}
