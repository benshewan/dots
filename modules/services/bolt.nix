{
  flake.modules.nixos."services/bolt" = {pkgs, ...}: {
    services.hardware.bolt.enable = true;
  };

  # Preservation companion for "services/bolt" (auto-resolved by the prefix).
  flake.modules.nixos."preservation/services/bolt" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.directories = [
      # Authorized Thunderbolt devices and dock keys.
      "/var/lib/boltd"
    ];
  };
}
