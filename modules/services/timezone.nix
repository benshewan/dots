{config, ...}: {
  flake.modules.nixos."services/timezone" = {pkgs, ...}: {
    services.automatic-timezoned.enable = true;

    services.geoclue2 = {
      enable = true;
      submitData = true;
      geoProviderUrl = "https://api.beacondb.net/v1/geolocate";
      submissionUrl = "https://api.beacondb.net/v2/geosubmit";
    };
  };
}
