{
  pkgs,
  outputs,
  config,
  ...
}: let
  # this line prevents hanging on network split
  automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
  credentials = "${outputs.src}/secrets/smb-secrets";
in {
  networking = {
    networkmanager.enable = true;
  };

  # Network Shares

  # For mount.cifs, required unless domain name resolution is not needed.
  environment.systemPackages = [pkgs.cifs-utils];

  fileSystems."/home/${config.night-sky.user.name}/Shares/backup" = {
    device = "//100.91.115.100/backup";
    fsType = "cifs";
    options = ["${automount_opts},credentials=${credentials},uid=1000,gid=991"];
  };
  fileSystems."/home/${config.night-sky.user.name}/Shares/media" = {
    device = "//100.91.115.100/media";
    fsType = "cifs";
    options = ["${automount_opts},credentials=${credentials},uid=1000,gid=991"];
  };
  fileSystems."/home/${config.night-sky.user.name}/Shares/downloads" = {
    device = "//100.91.115.100/downloads";
    fsType = "cifs";
    options = ["${automount_opts},credentials=${credentials},uid=1000,gid=991"];
  };
}
