{config, ...}: {
  # NixOS
  flake.modules.nixos.system = {...}: {
    networking.networkmanager.enable = true;
    networking.networkmanager.dns = "dnsmasq";
    users.users.${config.flake.meta.user.username}.extraGroups = ["networkmanager"];
  };

  flake.modules.nixos."preservation/system" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.directories = [
      # Saved connection profiles.
      "/etc/NetworkManager/system-connections"
      # Device and connection bookkeeping.
      "/var/lib/NetworkManager"
    ];
  };
}
