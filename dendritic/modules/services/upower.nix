_: {
  flake.modules.nixos."services/upower" = {pkgs, ...}: {
    # For handling battery powered devices i.e. laptops
    services.upower = {
      enable = true;
      percentageCritical = 15;
      criticalPowerAction = "Hibernate";
    };
  };
}
