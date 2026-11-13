{
  flake.modules.nixos."services/power-profiles-daemon" = {pkgs, ...}: {
    services.power-profiles-daemon.enable = true;
  };

  # Preservation companion for "services/power-profiles-daemon"
  # (auto-resolved by the prefix).
  flake.modules.nixos."preservation/services/power-profiles-daemon" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.directories = [
      # Active profile and configured actions (charge limit, GPU DPM).
      "/var/lib/power-profiles-daemon"
    ];
  };
}
