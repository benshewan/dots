{
  pkgs,
  outputs,
  config,
  ...
}: let
  # this line prevents hanging on network split
  automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
  credentials = "${outputs.flake-path}/secrets/smb-secrets";
in {
  networking = {
    networkmanager.enable = true;
  };

  # Network Shares

  # For mount.cifs, required unless domain name resolution is not needed.
  environment.systemPackages = [pkgs.cifs-utils];

  fileSystems."/home/${outputs.username}/Shares/backup" = {
    device = "//192.168.2.39/backup";
    fsType = "cifs";
    options = ["${automount_opts},credentials=${credentials},uid=1000,gid=100"];
  };
  fileSystems."/home/${outputs.username}/Shares/media" = {
    device = "//192.168.2.39/media";
    fsType = "cifs";
    options = ["${automount_opts},credentials=${credentials},uid=1000,gid=100"];
  };
  fileSystems."/home/${outputs.username}/Shares/downloads" = {
    device = "//192.168.2.39/downloads";
    fsType = "cifs";
    options = ["${automount_opts},credentials=${credentials},uid=1000,gid=100"];
  };
}
