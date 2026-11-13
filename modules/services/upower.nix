_: {
  flake.modules.nixos."services/upower" = {...}: {
    # For handling battery powered devices i.e. laptops
    services.upower = {
      enable = true;
      percentageCritical = 15;
      criticalPowerAction = "Hibernate";
    };
  };

  # Preservation companion for "services/upower" (auto-resolved by the prefix).
  flake.modules.nixos."preservation/services/upower" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.directories = [
      # Battery charge history.
      "/var/lib/upower"
    ];
  };
}
