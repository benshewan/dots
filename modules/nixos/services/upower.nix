{...}: {
  services.upower = {
    enable = true;
    percentageCritical = 15;
    criticalPowerAction = "Hibernate";
  };
}
