_: {
  flake.modules.nixos."services/tailscale" = {pkgs, ...}: {
    services.tailscale = {
      enable = true;
    };
  };

  # Preservation companion for "services/tailscale". `config.flake.lib.resolve`
  # imports it (together with the base preservation module) automatically
  # because of the "preservation/" prefix. Upstream ignores `preserveAt` until
  # `preservation.enable` is true, so no guard is needed here.
  flake.modules.nixos."preservation/services/tailscale" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.directories = [
      # Node identity and keys; without this the node re-enrols on every boot.
      "/var/lib/tailscale"
    ];
  };
}
