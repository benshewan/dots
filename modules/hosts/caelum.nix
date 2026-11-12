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
        "presets/mangowm"
        "theme/gruvbox-dark"

        # Storage: disko layout + preservation state management
        "disko"
        "preservation"

        # Software
        "programs/adb"
        "programs/yazi"
        # "programs/dolphin"
        "programs/npm"
        "programs/python"
        # "services/kdeconnect"
        # "programs/obs"
        "programs/maki"
        # "programs/thunderbird"

        # hardware configuration
        ../../machines/caelum/hardware-configuration.nix

        # declarative disk layout (disko)
        ../../machines/caelum/disko.nix
      ];

      # Erase-your-darlings: everything durable is bind-mounted from
      # /persistent (see machines/caelum/disko.nix). Companions for ssh,
      # NetworkManager/sops and bluetooth attach automatically.
      modules.preservation.enable = true;
      preservation.preserveAt."/persistent".directories = [
        # User homes: the ~/.nix repo, cloned sources and sops host keys
        # (~/.config/sops) live here.
        "/home"
      ];

      environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = 1;
      services.qemuGuest.enable = true;
      # Home Manager configuration for user
      home-manager.users.${config.flake.meta.user.username} = {
        monitors = [
          {
            name = "name:Virtual-1";
            width = 3840;
            height = 2160;
            refreshRate = 60;
            scale = 2.0;
            primary = true;
          }
        ];
      };
    };

    networking.nameservers = hostMeta.dnsServers;

    # services.keylightd.enable = true;
  };
}
