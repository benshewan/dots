{...}: {
  networking.networkmanager.enable = true;

  # Need to set regulatory domain for AMD RZ616 wifi card
  hardware.wirelessRegulatoryDatabase = true;
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom="CA"
  '';
}
