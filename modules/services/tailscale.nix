_: {
  flake.modules.nixos."services/tailscale" = {...}: {
    services.tailscale = {
      enable = true;
    };
  };

  # Preservation companion for "services/tailscale" (auto-resolved by the prefix).
  flake.modules.nixos."preservation/services/tailscale" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.directories = [
      # Node identity and keys; without them the node re-enrols every boot.
      "/var/lib/tailscale"
    ];
  };
}
