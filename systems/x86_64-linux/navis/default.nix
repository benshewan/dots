{
  pkgs,
  lib,
  inputs,
  config,
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
    home.extraOptions = {
      night-sky = {
        desktops.hyprland.enable = true;
        programs = {
          firefox.enable = true;
          yazi.enable = true;
          zen.enable = false;
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
          virt-manager.enable = true;
        };
      };
    };
  };

  services.keylightd.enable = true;
  virtualisation.waydroid.enable = true;

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    extest.enable = true;
  };

  services.flatpak.packages = [
    # {
    #   appId = "com.parsecgaming.parsec";
    #   origin = "flathub";
    # }
    {
      appId = "org.jdownloader.JDownloader";
      origin = "flathub";
    }
    {
      appId = "com.moonlight_stream.Moonlight";
      origin = "flathub";
    }
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

  # Due to old version of webcord
  nixpkgs.config.permittedInsecurePackages = [
    "electron-36.9.5"
  ];
  environment.systemPackages = with pkgs;
    [
      # Audio Configuration https://github.com/ceiphr/ee-framework-presets
      # easyeffects
      powertop
      piper
      # lan-mouse
      # orca-slicer
      # night-sky.audio-share
      xemu
      parsec-bin
      jetbrains-toolbox
      bitwarden-desktop

      dotnet-sdk_10
      (jetbrains.rider.override {
        vmopts = ''
          -Xmx4G
          -Xms2G
          -Dawt.toolkit.name=WLToolkit
        '';
      })
      python3

      (proxmark3.override {withGeneric = true;})

      (vivaldi.override {
        proprietaryCodecs = true;
        enableWidevine = true;
      })

      night-sky.audiorelay
    ]
    # Development stuff
    ++ (with pkgs; [
      (android-studio.override {forceWayland = true;})
    ]);

  # displaylink
  boot.kernelModules = ["udl"];

  hardware.logitech.wireless = {
    enable = true;
    enableGraphical = true;
  };

  services.ddccontrol.enable = true;
  users.users.${config.night-sky.user.name}.extraGroups = ["i2c"];
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
  };
  # services.howdy.enable = true;
  # services.linux-enable-ir-emitter.enable = true;

  # hardware.openrazer.enable = true;
  # hardware.openrazer.users = [config.night-sky.user.name];

  # Work
  services.mongodb = {
    enable = true;
    package = pkgs.stable.mongodb;
  };

  networking.firewall.enable = true;
  # For expo
  networking.firewall.allowedTCPPorts = [
    8081
    7100 # Development
    7236 # Miracast
    7250 # Miracast
    59100 # Audio relay
    65530
    4242
  ];
  networking.firewall.allowedUDPPorts = [
    7236 # Miracast
    5353 # Miracast
    59100
    59200 # Audio relay
    65530
    4242
  ];

  services.pipewire.extraConfig.pipewire = {
    # "audio-share-sink" = {
    #   "context.objects" = [
    #     {
    #       factory = "adapter";
    #       args = {
    #         "factory.name" = "support.null-audio-sink";
    #         "node.name" = "Audio Share Sink";
    #         "media.class" = "Audio/Sink";
    #         "object.linger" = true;
    #         "audio.position" = ["FL" "FR"];
    #         "priority.session" = 1009;
    #         "priority.driver" = 1009;
    #         "monitor.channel-volumes" = true;
    #         "monitor.passthrough" = true;
    #       };
    #     }
    #   ];
    # };
    "10-null-sink" = {
      "context.objects" = [
        {
          factory = "adapter";
          args = {
            "factory.name" = "support.null-audio-sink";
            "node.name" = "audiorelay-virtual-mic-sink";
            "node.description" = "Virtual Mic Sink";
            "media.class" = "Audio/Sink";
            "audio.position" = "FL,FR";
          };
        }
      ];
    };
    "20-virtual-mic" = {
      "context.modules" = [
        {
          name = "libpipewire-module-loopback";
          args = {
            "capture.props" = {
              "node.target" = "audiorelay-virtual-mic-sink";
            };
            "playback.props" = {
              "node.name" = "audiorelay-virtual-mic";
              "node.description" = "Virtual Mic";
              "media.class" = "Audio/Source";
              "audio.position" = "FL,FR";
              "node.passive" = true;
            };
          };
        }
      ];
    };
  };

  # MongoDB Extenal access
  # MongoDB port [27017]
  # services.mongodb.bind_ip = "127.0.0.1,192.168.0.69";
  # services.mongodb.enableAuth = false;
  # services.mongodb.initialRootPassword = "Coldsteel@22";
}
