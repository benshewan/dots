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
  # rvn-pc: Dendritic host configuration for desktop workstation
  # Hardware: Custom desktop with Intel CPU and NVIDIA GPU
  # Role: Primary workstation for gaming, development, and daily use

  flake = {
    # Host metadata
    meta.hosts = [hostMeta];

    modules.nixos."hosts/${hostMeta.name}" = {pkgs, ...}: {
      imports = config.flake.lib.resolve [
        # Desktop preset (users, security, development, shell, system, desktop environment)
        "presets/laptop"
        "presets/hyprland"
        "theme/gruvbox-dark"

        # virtualization
        "virtualization/docker"
        "virtualization/libvirt"

        # Software
        "programs/adb"
        "services/keylightd"

        # hardware configuration
        ../../machines/navis/hardware.nix
        ../../machines/navis/hardware-configuration.nix

        inputs.nixos-hardware.nixosModules.framework-13-7040-amd
      ];
      environment.systemPackages = with pkgs; [local.audiorelay];

      # Home Manager configuration for user
      home-manager.users.${config.flake.meta.user.username} = {
        imports = config.flake.lib.resolveHm [
          "presets/laptop"
          "presets/hyprland"
          "programs/webstorm"
          "programs/yazi"
          "programs/spotify"
          "programs/obs"
          "programs/npm"
        ];
        home.packages = with pkgs; [
          distrobox
          kdePackages.kate
          mpv
          bottles
          wine
          # stable.kicad
          # plex-media-player
          # jellyfin-media-player
          # jetbrains.pycharm-professional
          # stable.moonlight-qt

          # Work stuff
          # teamviewer
          libreoffice-fresh
          gnome-network-displays
          # masterpdfeditor
          # local.wisenet-viewer # Link broken
          inkscape

          # Messing around
          syncthingtray
          stable.handbrake

          # Audio
          qpwgraph
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
      };
    };

    networking.nameservers = hostMeta.dnsServers;

    services.keylightd.enable = true;
  };
}
