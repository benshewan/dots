{
  pkgs,
  config,
  lib,
  ...
}: let
  # this line prevents hanging on network split
  automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
  # credentials = ./smb-secrets;
in {
  networking = {
    networkmanager.enable = true;
  };

  # Network Shares

  # For mount.cifs, required unless domain name resolution is not needed.
  environment.systemPackages = [pkgs.cifs-utils];

  # Needs secret management
  # fileSystems."/home/${config.night-sky.user.name}/Shares/backup" = {
  #   device = "//192.168.2.39/backup";
  #   fsType = "cifs";
  #   options = ["${automount_opts},credentials=${credentials},uid=1000,gid=100"];
  # };
  # fileSystems."/home/${config.night-sky.user.name}/Shares/media" = {
  #   device = "//192.168.2.39/media";
  #   fsType = "cifs";
  #   options = ["${automount_opts},credentials=${credentials},uid=1000,gid=100"];
  # };
  # fileSystems."/home/${config.night-sky.user.name}/Shares/downloads" = {
  #   device = "//192.168.2.39/downloads";
  #   fsType = "cifs";
  #   options = ["${automount_opts},credentials=${credentials},uid=1000,gid=100"];
  # };

  # Services from Orion
  networking.extraHosts =
    (lib.concatMapStrings (x: "100.68.3.84 " + x + ".benshewan.dev\n") [
      "plex"
      "sonarr"
      "radarr"
      "prowlarr"
      "overseerr"
      # "downloads"
      "auth"
      "tautulli"
      "invite"
      "portainer"
      "files"
      "admin"
      "stats"
      "nzb"
      "jellyfin"
      "actual"
    ])
    + ''
    '';
}
