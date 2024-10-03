{pkgs, ...}: {
  # Set your time zone.
  time.timeZone = "America/Halifax";
  services.automatic-timezoned.enable = true;
  services.geoclue2.enable = true;
  programs.gnupg.agent.pinentryPackage = pkgs.pinentry-qt;
}
