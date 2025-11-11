{config, ...}: {
  networking.networkmanager.enable = true;
  users.users.${config.night-sky.user.name}.extraGroups = ["networkmanager"];

  # # Disable NetworkManager's internal DNS resolution
  # networking.networkmanager.dns = "none";

  # # These options are unnecessary when managing DNS ourselves
  # networking.useDHCP = false;
  # networking.dhcpcd.enable = false;

  # # Configure DNS servers manually (this example uses Cloudflare and Google DNS)
  # # IPv6 DNS servers can be used here as well.
  # networking.nameservers = [
  #   "1.1.1.1"
  #   "1.0.0.1"
  #   "8.8.8.8"
  #   "8.8.4.4"
  # ];

  # Need to set regulatory domain for AMD RZ616 wifi card
  hardware.wirelessRegulatoryDatabase = true;
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom="CA"
  '';
}
