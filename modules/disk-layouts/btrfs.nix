# Plain, unencrypted single-disk btrfs layout with erase-your-darlings: GPT +
# ESP + btrfs pool whose root subvolume is rolled back to a pristine snapshot
# at every boot. This is disk-layouts/luks-btrfs without the LUKS container,
# TPM keyslots or Secure Boot — the right pairing when the threat model does
# not include physical/offline disk access (e.g. a VM whose disk lives on a
# trusted host: the guest can never be more secure than the host anyway).
#
#   <device> GPT:
#     ESP        1G          vfat   /boot
#     storage    rest        btrfs (subvolumes below)
#       root                 /      (rolled back to root-blank every boot)
#       nix                  /nix
#       persistent           /persistent
#       swap (optional)      /persistent/swap  (nodatacow, when swapSize != null)
#
# Because / is wiped at every boot, all durable state must be bind-mounted
# from /persistent — this layout asserts that preservation is enabled (the
# "preservation" base module plus each feature's `preservation/<feature>`
# companions supply the entries).
#
# A host opts in with one import plus its parameters:
#
#   imports = config.flake.lib.resolve [
#     "disk-layouts/btrfs"
#     "preservation"
#   ];
#
#   modules.preservation.enable = true;
#   modules.diskLayouts.btrfs = {
#     device = "/dev/vda";   # required: the whole disk is claimed
#     swapSize = null;       # MiB; null = no swap (servers usually skip it,
#                            # and there is no hibernation support here)
#   };
{config, ...}: let
  diskoModule = config.flake.lib.resolve ["disko"];
in {
  flake.modules.nixos."disk-layouts/btrfs" = {
    config,
    lib,
    ...
  }: let
    cfg = config.modules.diskLayouts.btrfs;
    # Where the preservation module expects the durable state. The layout
    # creates its persistent subvolume at /persistent, so anything else is an
    # error (asserted below); the `or` keeps a host that forgot preservation
    # evaluating far enough to hit that assertion.
    persistentPath = config.modules.preservation.persistentPath or "/persistent";
    # The layout owns exactly one disk; partlabels follow disko's
    # disk-<disk>-<partition> scheme and are the stable way to name the pool
    # for the root-blank snapshot and the initrd rollback.
    diskName = "main";
    poolDevice = "/dev/disk/by-partlabel/disk-${diskName}-storage";
  in {
    imports = diskoModule;

    options.modules.diskLayouts.btrfs = {
      device = lib.mkOption {
        type = lib.types.str;
        example = "/dev/vda";
        description = ''
          Block device that becomes the ESP + btrfs pool. The whole disk is
          repartitioned by disko at install time, so anything already on it is
          destroyed.
        '';
      };
      swapSize = lib.mkOption {
        type = lib.types.nullOr lib.types.ints.positive;
        default = null;
        description = ''
          Size in MiB of a swapfile on the `swap` subvolume. null = no swap.
          There is no hibernation support in this layout, so swap only serves
          as memory pressure relief.
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
              priority = 2;
              content = {
                type = "btrfs";
                extraArgs = ["-L" "storage" "-f"];
                subvolumes =
                  {
                    "root" = {
                      mountpoint = "/";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "nix" = {
                      mountpoint = "/nix";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "persistent" = {
                      mountpoint = "/persistent";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                  }
                  // lib.optionalAttrs (cfg.swapSize != null) {
                    # Separate subvolume for the swapfile: mounting it with
                    # nodatacow means the file needs no +C chattr and is never
                    # compressed, and keeping it out of `persistent` means a
                    # future `btrfs subvolume snapshot /persistent` stays small.
                    "swap" = {
                      mountpoint = "/persistent/swap";
                      mountOptions = ["nodatacow" "noatime"];
                    };
                  };
                # root-blank is NOT declared as a subvolume: it is created here
                # as a READONLY snapshot of the still-empty root subvolume, so
                # the pristine state the initrd rolls back to can never drift.
                # (-r matters: a writable blank would silently accumulate any
                # change made through a future mistake in the rollback script.)
                postCreateHook = ''
                  MNTPOINT=$(mktemp -d)
                  mount -t btrfs -o subvol=/ ${lib.escapeShellArg poolDevice} "$MNTPOINT"
                  trap 'umount "$MNTPOINT"; rm -rf "$MNTPOINT"' EXIT
                  btrfs subvolume snapshot -r "$MNTPOINT"/root "$MNTPOINT"/root-blank
                '';
              };
            };
          };
        };
      };

      # disko does not set neededForBoot: preservation bind-mounts state
      # (machine-id, /var/lib/nixos) from /persistent in the initrd, and the
      # nix store must be present for activation.
      fileSystems."/persistent".neededForBoot = true;
      fileSystems."/nix".neededForBoot = true;

      boot.supportedFilesystems = ["btrfs"];

      swapDevices = lib.optional (cfg.swapSize != null) {
        device = "/persistent/swap/swapfile";
        size = cfg.swapSize;
      };

      services.btrfs.autoScrub = {
        enable = true;
        interval = "monthly";
      };

      # btrfs frees space via periodic fstrim (no automatic discards), which
      # keeps a VM image from growing monotonically.
      services.fstrim.enable = true;

      boot.initrd.systemd.services.rollback = {
        description = "Roll back the btrfs root subvolume to a pristine snapshot";
        wantedBy = ["initrd.target"];
        # Ordered After= local-fs-pre.target so a future resume-capable variant
        # cannot race the rollback against the hibernation-resume check
        # (Discourse 39955, systemd PR #26348); on a normal boot the resume
        # unit is absent and this simply runs before sysroot is mounted.
        requires = ["initrd-root-device.target"];
        after = [
          "initrd-root-device.target"
          "local-fs-pre.target"
        ];
        before = ["sysroot.mount"];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
          mkdir -p /mnt
          # Explicit -t: autodetection can misdetect the partition (a stale
          # NTFS signature from a previous image makes mount pick fuseblk,
          # which then rejects `subvol=` and fails the whole rollback).
          mount -t btrfs -o subvol=/ ${lib.escapeShellArg poolDevice} /mnt

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

      # Erase-your-darlings is only meaningful with state preservation: the
      # initrd deletes the root subvolume and recreates it from root-blank at
      # every boot, so without bind-mounted state the machine loses /home,
      # ssh host keys, sops keys, logs, ... on each boot. Fail the evaluation
      # instead of a deployment/reboot.
      assertions = [
        {
          assertion = config.modules.preservation.enable or false;
          message = ''
            modules.diskLayouts.btrfs wipes the btrfs root at every boot and
            expects durable state to be bind-mounted from /persistent. Resolve
            "preservation" and set modules.preservation.enable = true, or use
            a layout that keeps / (e.g. "disk-layouts/ext4").
          '';
        }
        {
          assertion = persistentPath == "/persistent";
          message = ''
            modules.diskLayouts.btrfs creates the persistent subvolume (and
            everything that lives on it) at /persistent, but
            modules.preservation.persistentPath is ${persistentPath}. Preserved
            state would bind-mount from a path this layout does not create.
          '';
        }
      ];
    };
  };
}
