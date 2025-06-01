{...}: {
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "systemd-resolved";
  networking.nameservers = ["1.1.1.1" "8.8.8.8"];

  # Need to set regulatory domain for AMD RZ616 wifi card
  hardware.wirelessRegulatoryDatabase = true;
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom="CA"
  '';
}
