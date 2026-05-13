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
      # age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEDg4CemGcdSt0uDCZ5yBUyBswjBdzo6MrIz1wztSS+O root@navis";
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
        "services/tailscale"
        "programs/solaar"
        "services/kdeconnect"
        "programs/lan-mouse"
        "programs/vivaldi"
        "programs/yazi"
        "programs/spotify"
        "programs/obs"
        "programs/chromium"
        "programs/mongodb-compass"
        "programs/filebot"
        "programs/bottles"
        "programs/prism-launcher"
        "programs/partition-manager"
        "programs/dolphin"
        "programs/helium"

        # Programming
        "programs/webstorm"
        "programs/zed"
        "programs/npm"
        "programs/python"
        "programs/claude-code"

        # hardware configuration
        ../../machines/navis/hardware.nix
        ../../machines/navis/hardware-configuration.nix

        inputs.nixos-hardware.nixosModules.framework-13-7040-amd
      ];
      boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-zen4;

      environment.systemPackages = with pkgs; [local.audiorelay];
      services.mongodb = {
        enable = true;
        package = pkgs.stable.mongodb;
      };
      programs.yubikey-manager.enable = true;

      networking.firewall = rec {
        allowedTCPPorts = [
          7100
        ];
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
          inkscape
          parsec-bin

          # Messing around
          syncthingtray
          stable.handbrake
          brasero

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

    # networking.nameservers = hostMeta.dnsServers;

    services.keylightd.enable = true;
  };
}
