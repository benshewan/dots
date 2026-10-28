{
  inputs,
  config,
  ...
}: let
  hostMeta = {
    name = "navis";
    dnsServers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
  };
in {
  # Hardware: Framework 13 AMD 7840U
  # Role: Primary Machine, both for work and personal

  flake = {
    # Host metadata
    meta.hosts = [hostMeta];

    modules.nixos."hosts/${hostMeta.name}" = {pkgs, ...}: {
      users.users.${config.flake.meta.user.username}.openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDDfq19XAukOGrSyQoVQBf5Yq629cqq/+gaDCnxil4+i gaming-vm"];
      imports = config.flake.lib.resolve [
        # Desktop preset (users, security, development, shell, system, desktop environment)
        "presets/laptop"
        "presets/mangowm"
        "theme/everforest"

        # virtualization
        "virtualization/docker"
        "virtualization/libvirt"

        # Software
        "programs/adb"
        "services/keylightd"
        "services/tailscale"
        "programs/solaar"
        "services/kdeconnect"
        # "programs/lan-mouse"
        "programs/yazi"
        # "programs/spotify"
        "programs/obs"
        "programs/chromium"
        # "programs/filebot"
        "programs/bottles"
        "programs/prism-launcher"
        "programs/partition-manager"
        "programs/dolphin"
        # "programs/helium"
        "programs/obsidian"
        # "services/sunshine"
        # "programs/steam"
        "programs/brave"
        # "services/easyeffects"

        # Programming
        # "programs/webstorm"
        "programs/vscode"
        "programs/nvim"
        "programs/helix"
        "programs/npm"
        "programs/python"
        "programs/maki"
        "programs/rea"
        # "programs/pi"
        # "programs/opencode"
        # "programs/opencode2"

        # hardware configuration
        ../../machines/navis/hardware.nix
        ../../machines/navis/hardware-configuration.nix

        inputs.nixos-hardware.nixosModules.framework-13-7040-amd
      ];
      boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-zen4;

      services.keylightd.enable = true;

      # Because of stylix forcing a rebuild updates take forever otherwise
      services.flatpak.packages = [
        {appId = "org.inkscape.Inkscape";}
      ];

      networking.firewall = {
        allowedTCPPorts = [
          7100 # freecore
          59100 # audio relay
          7236 7250 # miracast
        ];
        allowedUDPPorts = [
          59100 59200 # audio relay
          7236 5353 # miracast
        ];
      };
      services.pipewire.extraConfig.pipewire = {
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
      # Home Manager configuration for user
      home-manager.users.${config.flake.meta.user.username} = {
        home.packages = with pkgs; [
          distrobox
          kdePackages.kate
          mpv
          moonlight-qt
          (stable.proxmark3.override {withGeneric = true;})
          chameleon-cli
          wdisplays

          # Work stuff
          libreoffice-stable
          yaak
          parsec-bin
          github-cli

          # Messing around
          # syncthingtray
          keyguard
          # stable.handbrake
          # brasero # CD burning/copying
          # local.audiorelay
          stable.orca-slicer

          # Audio
          qpwgraph
        ];

        monitors = [
          # Internal Monitor
          {
            name = "name:eDP-1";
            width = 2256;
            height = 1504;
            primary = true;
            scale = 1.566667;
            x = 2048;
            y = 1152;
          }

          # Home Monitors
          {
            # Lenovo Group Limited P24q-10 U4P00001
            name = "serial:U4P00001";
            # rotate = 1;
            width = 2560;
            height = 1440;
            scale = 1.25;
            y = 0;
            x = 0;
          }
          {
            # "Dell Inc. AW3423DWF 58082S3
            name = "serial:58082S3";
            width = 3440;
            height = 1440;
            refreshRate = 165;
            # colorProfile = "hdr";
            scale = 1.25;
            x = 2048;
            y = 0;
          }
        ];

        # Default applications. Whatever a package declares in its own
        # `.desktop` `MimeType=` becomes a default automatically, so only real
        # conflicts (two installed apps claiming the same type) need overrides.
        xdg.mimeApps = {
          enable = true;

          defaultApplicationPackages = with pkgs; [
            firefox-devedition
            mpv # all video/* and audio/* types
            kdePackages.ark # zip/tar/7z/rar/xz/bz2
            loupe # image/*
            foliate # epub/mobi/fb2/cbz + x-scheme-handler/opds
          ];

          defaultApplications = {
            # vscode also claims text/xml + application/json
            "text/plain" = "org.kde.kate.desktop";
            "text/xml" = "org.kde.kate.desktop";
            "application/json" = "org.kde.kate.desktop";

            # dolphin and ark also claim inode/directory
            "inode/directory" = "yazi.desktop";
          };
        };
      };
    };

    # networking.nameservers = hostMeta.dnsServers;
  };
}
