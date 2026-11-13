# Plain, unencrypted single-disk layout: GPT + ESP + ext4 root with an optional
# swap file. This is the scheme of a stock `nixos-generate-config` install (what
# navis runs), except swap lives in /swapfile on the root filesystem instead of
# a swap partition. No LUKS, no snapshots, no erase-your-darlings — state and
# data simply live on /.
#
#   <device> GPT:
#     ESP    <espSize>   vfat   /boot
#     root   rest        ext4   /  (plus /swapfile when swapSize != null)
#
# A host opts in with one import plus its parameters:
#
#   imports = config.flake.lib.resolve [
#     "disk-layouts/ext4"
#   ];
#
#   modules.diskLayouts.ext4 = {
#     device = "/dev/nvme0n1";   # required: the whole disk is claimed
#     swapSize = 16 * 1024;      # MiB; null = no swap
#   };
#
# Hibernation: systemd-sleep records the image location (the block device's
# filesystem UUID plus the swap file's page offset, computed through FIEMAP) in
# the HibernateLocation EFI variable, and the initrd resume generator uses it
# when `resume=` is absent. boot.resumeDevice is therefore deliberately left
# unset — with `resume=` on the cmdline systemd prefers it and defaults
# resume_offset to 0 (the start of the partition, not the swap header), so
# neither hibernating nor resuming works. This requires EFI boot. NixOS creates
# /swapfile with dd on first activation, so the file is fully allocated;
# swapon rejects sparse files.
#
# Trade-offs against disk-layouts/luks-btrfs: everything on the disk is
# readable at rest and there is no wiped/rolled-back root; in exchange the
# layout needs no TPM, Secure Boot or post-install provisioning and is trivial
# to reason about. Disk and swap are unencrypted: a hibernation image (a full
# RAM snapshot) is written in the clear, so do not hibernate a machine that
# holds disk-encryption keys in memory.
{config, ...}: let
  diskoModule = config.flake.lib.resolve ["disko"];
in {
  flake.modules.nixos."disk-layouts/ext4" = {
    config,
    lib,
    ...
  }: let
    cfg = config.modules.diskLayouts.ext4;
    # The layout owns exactly one disk.
    diskName = "main";
  in {
    imports = diskoModule;

    options.modules.diskLayouts.ext4 = {
      device = lib.mkOption {
        type = lib.types.str;
        example = "/dev/nvme0n1";
        description = ''
          Block device that becomes the ESP + ext4 root. The whole disk is
          repartitioned by disko at install time, so anything already on it is
          destroyed.
        '';
      };
      espSize = lib.mkOption {
        type = lib.types.str;
        default = "1G";
        description = ''
          Size of the vfat ESP mounted at /boot. Leave headroom for several
          kernel + initrd generations (and lanzaboote UKIs, which are larger).
        '';
      };
      swapSize = lib.mkOption {
        type = lib.types.nullOr lib.types.ints.positive;
        default = 16 * 1024;
        example = 68 * 1024;
        description = ''
          Size in MiB of the /swapfile on the root filesystem. Set to null to
          omit swap. Hibernation needs at least as much swap as RAM; the file
          shares the ext4 free space, so root must have room for it.
        '';
      };
    };

    config = {
      disko.devices.disk.${diskName} = {
        type = "disk";
        device = cfg.device;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = cfg.espSize;
              type = "EF00";
              priority = 1;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                # Same as the luks-btrfs layout: the ESP holds no secrets, but
                # there is no reason for other users to read or write it.
                mountOptions = ["fmask=0077" "dmask=0077"];
              };
            };
            root = {
              size = "100%";
              priority = 2;
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
                extraArgs = ["-L" "nixos"];
              };
            };
          };
        };
      };

      # Swap file on the root filesystem (see the header for why there is no
      # boot.resumeDevice). NixOS creates and mkswap's it on first activation;
      # the entry disappears entirely when swapSize is null.
      swapDevices = lib.optional (cfg.swapSize != null) {
        device = "/swapfile";
        size = cfg.swapSize;
      };
    };
  };
}
