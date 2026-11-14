{config, ...}: let
  hostMeta = {
    name = "apus";
    dnsServers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
  };
in {
  # Hardware: none yet — nixos-anywhere generates
  # machines/apus/hardware-configuration.nix during the install (README step 3).
  # Role: headless server VM; plain btrfs disk layout with erased root
  # (no LUKS, no Secure Boot — a VM's disk lives on its trusted host).

  flake = {
    # Host metadata
    meta.hosts = [hostMeta];

    modules.nixos."hosts/apus" = {
      # Rescue access: plain authorized keys work even if sops decryption
      # fails (no declarative password hash set on a fresh install).
      users.users.${config.flake.meta.user.username}.openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMm0WtaU9Sb6g9UC+HFL6h4L+rOsHUMN/iWOU3qRGgaI benbshewan@gmail.com"];

      imports = config.flake.lib.resolve [
        # Server base (users, ssh, system)
        "presets/server"

        # Disk: wiped btrfs root + preservation (state bind-mounted from
        # /persistent); machine-specific modules under machines/apus/* attach
        # automatically
        "disk-layouts/btrfs"
        "preservation"
        "system/preservation-home"
      ];

      # Erase-your-darlings: everything durable is bind-mounted from
      # /persistent (see modules/disk-layouts/btrfs.nix). Companions for ssh,
      # sops and NetworkManager attach automatically. User state is granular
      # (system/preservation-home) instead of a wholesale /home mount.
      modules.preservation.enable = true;
      modules.preservation.home = true;

      # Machine-specific parameters for the shared layout
      # (modules/disk-layouts/btrfs.nix).
      # TODO: set apus's actual disk before installing (README step 3) —
      # the whole disk is claimed (ESP + btrfs pool).
      modules.diskLayouts.btrfs = {
        device = "/dev/vda";
        swapSize = 4 * 1024;
      };

      # Server-only tweaks (services, firewall, ...) go here
    };
  };
}
