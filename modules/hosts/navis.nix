{
  inputs,
  config,
  lib,
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
      age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEDg4CemGcdSt0uDCZ5yBUyBswjBdzo6MrIz1wztSS+O root@navis";
      imports = config.flake.lib.resolve [
        # Desktop preset (users, security, development, shell, system, desktop environment)
        "presets/laptop"
        "presets/mangowm"
        "theme/gruvbox-dark"

        # virtualization
        "virtualization/docker"
        "virtualization/libvirt"

        # Software
        "programs/adb"
        "services/keylightd"
        "services/tailscale"
        "programs/solaar"
        "services/kdeconnect"
        "programs/lan-mouse"
        "programs/vivaldi"
        "programs/yazi"
        # "programs/spotify"
        "programs/obs"
        "programs/chromium"
        "programs/mongodb-compass"
        # "programs/filebot"
        "programs/bottles"
        "programs/prism-launcher"
        "programs/partition-manager"
        "programs/dolphin"
        # "programs/helium"
        "programs/obsidian"
        # "services/sunshine"
        "programs/steam"
        "programs/brave"
        # "services/easyeffects"

        # Programming
        # "programs/webstorm"
        "programs/vscode"
        "programs/npm"
        "programs/python"
        # "programs/claude-code"
        "programs/opencode"
        "programs/maki"

        # hardware configuration
        ../../machines/navis/hardware.nix
        ../../machines/navis/hardware-configuration.nix

        inputs.nixos-hardware.nixosModules.framework-13-7040-amd
      ];
      boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-zen4;

      services.mongodb = {
        enable = true;
        package = pkgs.stable.mongodb;
      };
      services.keylightd.enable = true;

      # Because of stylix forcing a rebuild updates take forever otherwise
      services.flatpak.packages = [
        {appId = "org.inkscape.Inkscape";}
      ];

      networking.firewall = {
        allowedTCPPorts = [
          7100 # freecore
          59100 # audio relay
        ];
        allowedUDPPorts = [59100 59200]; # audio relay
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
          (proxmark3.override {withGeneric = true;})
          chameleon-cli

          # Work stuff
          libreoffice-fresh
          gnome-network-displays
          local.wisenet-viewer
          yaak
          parsec-bin

          # Messing around
          syncthingtray
          stable.handbrake
          brasero
          local.audiorelay
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

          # Work Monitors
          {
            # Dell Inc. DELL P2417H KH0NG95K15KL
            name = "serial:KH0NG95K15KL";
            width = 1920;
            height = 1080;
            x = 1031;
            y = 72;
          }
          {
            # Dell Inc. DELL P2417H KH0NG95F0AMI
            name = "serial:KH0NG95F0AMI";
            width = 1920;
            height = 1080;
            x = 2951;
            y = 72;
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
            scale = 1.25;
            x = 2048;
            y = 0;
          }
        ];

        # ---------------------------------------------temp------------------------------------------------------------
        # Enable xdg.mimeApps to manage default applications
        xdg.mimeApps.enable = true;

        # Configure default applications for specific MIME types and URL schemes
        xdg.mimeApps.defaultApplications = {
          # Browser files
          "text/html" = "firefox-devedition.desktop";
          "x-scheme-handler/http" = "firefox-devedition.desktop";
          "x-scheme-handler/https" = "firefox-devedition.desktop";

          # Text files
          "text/plain" = "org.kde.kate.desktop";
          "text/xml" = "org.kde.kate.desktop";
          "application/json" = "org.kde.kate.desktop";

          # Compressed files
          "application/zip" = "ark.desktop";
          "application/gzip" = "ark.desktop";
          "application/tar" = "ark.desktop";
          "application/bzip2" = "ark.desktop";
          "application/7z-compressed" = "ark.desktop";
          "application/rar" = "ark.desktop";
          "application/xz" = "ark.desktop";
          "application/bzip" = "ark.desktop";

          # Document files

          # Image files
          "image/jpeg" = "org.gnome.Loupe.desktop";
          "image/png" = "org.gnome.Loupe.desktop";
          # File browser
          "inode/directory" = "yazi.desktop";

          # Ebook files
          "application/epub+zip" = "com.github.johnfactotum.Foliate.desktop";
          "application/x-mobipocket-ebook" = "com.github.johnfactotum.Foliate.desktop";
          "application/vnd.amazon.mobi8-ebook" = "com.github.johnfactotum.Foliate.desktop";
          "application/x-fictionbook+xml" = "com.github.johnfactotum.Foliate.desktop";
          "application/x-zip-compressed-fb2" = "com.github.johnfactotum.Foliate.desktop";
          "application/vnd.comicbook+zip" = "com.github.johnfactotum.Foliate.desktop";
          "x-scheme-handler/opds" = "com.github.johnfactotum.Foliate.desktop";

          # Video files
          "video/" = "mpv.desktop";
          "audio/" = "mpv.desktop";
          "application/ogg" = "mpv.desktop";
          "application/x-ogg" = "mpv.desktop";
          "application/mxf" = "mpv.desktop";
          "application/sdp" = "mpv.desktop";
          "application/smil" = "mpv.desktop";
          "application/x-smil" = "mpv.desktop";
          "application/streamingmedia" = "mpv.desktop";
          "application/x-streamingmedia" = "mpv.desktop";
          "application/vnd.rn-realmedia" = "mpv.desktop";
          "application/vnd.rn-realmedia-vbr" = "mpv.desktop";
          "application/x-extension-m4a" = "mpv.desktop";
          "application/x-extension-mp4" = "mpv.desktop";
          "application/vnd.ms-asf" = "mpv.desktop";
          "application/x-matroska" = "mpv.desktop";
          "application/x-ogm" = "mpv.desktop";
          "application/x-ogm-audio" = "mpv.desktop";
          "application/x-ogm-video" = "mpv.desktop";
          "application/x-shorten" = "mpv.desktop";
          "application/x-mpegurl" = "mpv.desktop";
          "application/vnd.apple.mpegurl" = "mpv.desktop";
          "application/x-cue" = "mpv.desktop";

          # Spreadsheets
          "application/clarisworks" = "calc.desktop";
          "application/csv" = "calc.desktop";
          "application/excel" = "calc.desktop";
          "application/msexcel" = "calc.desktop";
          "application/tab-separated-values" = "calc.desktop";
          "application/vnd.apache.parquet" = "calc.desktop";
          "application/vnd.apple.numbers" = "calc.desktop";
          "application/vnd.lotus-1-2-3" = "calc.desktop";
          "application/vnd.ms-excel" = "calc.desktop";
          "application/vnd.ms-excel.sheet.binary.macroEnabled.12" = "calc.desktop";
          "application/vnd.ms-excel.sheet.macroEnabled.12" = "calc.desktop";
          "application/vnd.ms-excel.template.macroEnabled.12" = "calc.desktop";
          "application/vnd.ms-works" = "calc.desktop";
          "application/vnd.oasis.opendocument.chart" = "calc.desktop";
          "application/vnd.oasis.opendocument.chart-template" = "calc.desktop";
          "application/vnd.oasis.opendocument.spreadsheet" = "calc.desktop";
          "application/vnd.oasis.opendocument.spreadsheet-flat-xml" = "calc.desktop";
          "application/vnd.oasis.opendocument.spreadsheet-template" = "calc.desktop";
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "calc.desktop";
          "application/vnd.openxmlformats-officedocument.spreadsheetml.template" = "calc.desktop";
          "application/vnd.stardivision.calc" = "calc.desktop";
          "application/vnd.stardivision.chart" = "calc.desktop";
          "application/vnd.sun.xml.calc" = "calc.desktop";
          "application/vnd.sun.xml.calc.template" = "calc.desktop";
          "application/x-123" = "calc.desktop";
          "application/x-dbase" = "calc.desktop";
          "application/x-dbf" = "calc.desktop";
          "application/x-dos_ms_excel" = "calc.desktop";
          "application/x-excel" = "calc.desktop";
          "application/x-gnumeric" = "calc.desktop";
          "application/x-iwork-numbers-sffnumbers" = "calc.desktop";
          "application/x-ms-excel" = "calc.desktop";
          "application/x-msexcel" = "calc.desktop";
          "application/x-quattropro" = "calc.desktop";
          "application/x-starcalc" = "calc.desktop";
          "application/x-starchart" = "calc.desktop";
          "text/comma-separated-values" = "calc.desktop";
          "text/csv" = "calc.desktop";
          "text/spreadsheet" = "calc.desktop";
          "text/tab-separated-values" = "calc.desktop";
          "text/x-comma-separated-values" = "calc.desktop";
          "text/x-csv" = "calc.desktop";
          # "application/pdf" = "zathura.desktop";
        };
        # ---------------------------------------------temp------------------------------------------------------------
      };
    };

    # networking.nameservers = hostMeta.dnsServers;
  };
}
