{pkgs, ...}: {
  # Set your time zone.
  time.timeZone = "America/Halifax";

  # Does not work as mozillas geoclue api was shut down, need o either use google or beaconDB
  # services.automatic-timezoned.enable = true;
  # services.geoclue2.enable = true;
  # services.geoclue2.geoProviderUrl = "https://www.googleapis.com/geolocation/v1/geolocate?key=YOUR_API_KEY";

  programs.gnupg.agent.pinentryPackage = pkgs.pinentry-qt;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
