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
      age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA1d78bzDG4zyENobh73Npv64fWDZY0sxK8WTVl4H4vJ root@caelum";
      imports = config.flake.lib.resolve [
        # Desktop preset (users, security, development, shell, system, desktop environment)
        "presets/desktop"
        "presets/mangowm"
        "theme/gruvbox-dark"

        # Software
        "programs/adb"
        "services/keylightd"
        "programs/webstorm"
        "programs/yazi"
        "programs/dolphin"
        "programs/npm"
        "programs/python"
        "services/kdeconnect"

        # hardware configuration
        ../../machines/caelum/hardware-configuration.nix
      ];

      # Home Manager configuration for user
      home-manager.users.${config.flake.meta.user.username} = {
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

    # services.keylightd.enable = true;
  };
}
