{
  config,
  pkgs,
  lib,
  ...
}: {
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

  # disable wifi when ethernet is connected, mostly to fix inconsistencies when streaming with moonlight
  networking.networkmanager.dispatcherScripts = [
    {
      source = pkgs.writeShellScript "ethernet-toggles-wifi" ''
        #!/usr/bin/env bash
        # Check if any interface of type 'ethernet' is currently 'connected'
        if ${lib.getExe' pkgs.networkmanager "nmcli"} -t -f TYPE,STATE dev | ${lib.getExe' pkgs.busybox "grep"} -q "^ethernet:connected"; then
          ${lib.getExe' pkgs.networkmanager "nmcli"} radio wifi off
        else
          ${lib.getExe' pkgs.networkmanager "nmcli"} radio wifi on
        fi
      '';
      type = "basic";
    }
  ];

  # Need to set regulatory domain for AMD RZ616 wifi card
  hardware.wirelessRegulatoryDatabase = true;
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom="CA"
  '';
}
