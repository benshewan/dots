{
  inputs,
  config,
  ...
}: let
  hostMeta = {
    name = "caelum";
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
        "presets/desktop"
        "presets/hyprland"
        "theme/gruvbox-dark"

        # virtualization
        "virtualization/docker"
        "virtualization/libvirt"

        # Software
        "programs/adb"
        "services/keylightd"

        # hardware configuration
        ../../machines/caelum/hardware-configuration.nix
      ];

      # Home Manager configuration for user
      home-manager.users.${config.flake.meta.user.username} = {
        imports = config.flake.lib.resolveHm [
          "presets/desktop"
          "presets/hyprland"
          "programs/webstorm"
          "programs/yazi"
          "programs/spotify"
          "programs/dolphin"
          "programs/prism-launcher"
          "programs/npm"
          "programs/python"
          "programs/vivaldi"
          "programs/chromium"
        ];

        monitors = [
          {
            name = "Virtual-1";
            width = 1920;
            height = 1080;
            refreshRate = 60;
            primary = true;
          }
        ];
      };
    };

    networking.nameservers = hostMeta.dnsServers;

    services.keylightd.enable = true;
  };
}
