# Disk layout for caelum (QEMU VM), erase-your-darlings with btrfs rollback:
#
#   /dev/vda GPT:
#     ESP      1G    vfat   /boot
#     storage  rest  btrfs  (single partition, subvolumes share free space)
#       root        /             wiped by the initrd rollback every boot
#       root-blank  (unmounted)   pristine snapshot restored into root
#       nix         /nix          nix store, survives reboots
#       persistent  /persistent   bind-mounted state lives here
#
# Unlike tmpfs root this has no RAM ceiling, and unlike separate ext4
# partitions /nix and /persistent share one free pool. `preservation`
# bind-mounts everything worth keeping back from /persistent, and /home is
# preserved by hosts/caelum.nix.
{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/vda";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            priority = 1;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["fmask=0077" "dmask=0077"];
            };
          };
          storage = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = ["-L" "storage" "-f"];
              subvolumes = {
                "root" = {
                  mountpoint = "/";
                  mountOptions = ["compress=zstd" "noatime"];
                };
                "root-blank" = {
                  # Created at install time, never mounted: frozen copy of the
                  # empty root subvolume.
                  mountpoint = null;
                };
                "nix" = {
                  mountpoint = "/nix";
                  mountOptions = ["compress=zstd" "noatime"];
                };
                "persistent" = {
                  mountpoint = "/persistent";
                  mountOptions = ["compress=zstd" "noatime"];
                };
              };
            };
          };
        };
      };
    };
  };

  # disko does not set neededForBoot: preservation bind-mounts state
  # (machine-id, /var/lib/nixos) from /persistent in the initrd, and the nix
  # store must be present for activation.
  fileSystems."/persistent".neededForBoot = true;
  fileSystems."/nix".neededForBoot = true;

  boot.supportedFilesystems = ["btrfs"];

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
  };

  boot.initrd.systemd.services.rollback = {
    description = "Roll back the btrfs root subvolume to a pristine snapshot";
    wantedBy = ["initrd.target"];
    # This nixpkgs is systemd-initrd only: `postDeviceCommands` (as seen in
    # older guides) silently does nothing here. Order after the root device
    # node and before the root mount.
    after = ["dev-disk-by\\x2dpartlabel-disk\\x2dmain-storage.device"];
    before = ["sysroot.mount"];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /mnt
      mount -o subvol=/ /dev/disk/by-partlabel/disk-main-storage /mnt

      # /root can gain nested subvolumes (systemd-nspawn machinery), which
      # make a plain delete fail; remove them first.
      btrfs subvolume list -o /mnt/root |
        cut -f9 -d' ' |
        while read -r subvolume; do
          btrfs subvolume delete "/mnt/$subvolume"
        done
      btrfs subvolume delete /mnt/root

      btrfs subvolume snapshot /mnt/root-blank /mnt/root
      umount /mnt
    '';
  };
}
