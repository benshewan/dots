# Generic single-disk layout: GPT + LUKS2 + btrfs with an erase-your-darlings
# root, rolled back to a pristine snapshot at every boot.
#
#   <device> GPT:
#     ESP      1G    vfat   /boot (unencrypted)
#     storage  rest  LUKS2  passphrase unlocked in the initrd
#              btrfs on /dev/mapper/crypt (subvolumes share free space)
#       root        /             wiped by the initrd rollback every boot
#       root-blank  (unmounted)   pristine READONLY snapshot restored into root
#       nix         /nix          nix store, survives reboots
#       persistent  /persistent   bind-mounted state lives here
#       swap        /persistent/swap   hibernation swapfile only, its own
#                                 subvolume so snapshots of `persistent`
#                                 never drag a 16G NOCOW file along
#
# Swap is a file INSIDE the LUKS container, not a partition: a hibernation
# image is a full RAM snapshot (including the LUKS volume key), so plaintext
# swap next to encrypted storage would leak the whole scheme. It lives in its
# own subvolume on the same filesystem, so it survives the root rollback, never
# moves (stable physical offset, pinned into the HibernateLocation EFI variable
# at hibernate time), and stays out of any future `persistent` snapshot.
#
# Unlike tmpfs root this has no RAM ceiling, and unlike separate ext4
# partitions /nix and /persistent share one free pool. `preservation`
# bind-mounts everything worth keeping back from /persistent, and /home is
# preserved by the host module.
#
# A host opts in with one import plus the machine-specific parameters:
#
#   imports = config.flake.lib.resolve [
#     "preservation"
#     "disk-layouts/luks-btrfs"
#   ];
#
#   modules.diskLayouts.luksBtrfs = {
#     device = "/dev/nvme0n1";   # required: the whole disk is claimed
#     swapSize = 32 * 1024;      # MiB; must be >= RAM to hibernate
#   };
#
# Keyslot provisioning (TPM/pcrlock enrollment, recovery keys, FIDO2) is not
# part of the layout: it runs on the installed system. The stable container
# path for such tooling is modules.diskLayouts.luksBtrfs.luksDevice.
{config, ...}: let
  # Resolved at flake level: inside the NixOS module below, `config` is the
  # host's NixOS config, where config.flake does not exist.
  diskoModule = config.flake.lib.resolve ["disko"];
in {
  flake.modules.nixos."disk-layouts/luks-btrfs" = {
    config,
    lib,
    options,
    ...
  }: let
    cfg = config.modules.diskLayouts.luksBtrfs;
    # Where the preservation module expects the durable state. The layout
    # creates its persistent subvolume at /persistent, so anything else is an
    # error (asserted below); the `or` keeps a host that forgot preservation
    # evaluating far enough to hit that assertion.
    persistentPath = config.modules.preservation.persistentPath or "/persistent";
    # The layout owns exactly one disk; these names are what the partlabels
    # (`disk-main-storage`) and the mapper name (`crypt`) are derived from.
    diskName = "main";
    luksName = "crypt";
  in {
    imports = diskoModule;

    options.modules.diskLayouts.luksBtrfs = {
      device = lib.mkOption {
        type = lib.types.str;
        example = "/dev/nvme0n1";
        description = ''
          Block device that becomes the ESP + encrypted btrfs pool. The whole
          disk is repartitioned by disko at install time, so anything already
          on it is destroyed.
        '';
      };
      swapSize = lib.mkOption {
        type = lib.types.ints.positive;
        default = 16 * 1024;
        description = ''
          Size in MiB of the hibernation swapfile on the `swap` subvolume.
          Hibernation needs at least as much swap as RAM.
        '';
      };
      luksPassphraseFile = lib.mkOption {
        type = lib.types.str;
        default = "/tmp/luks-passphrase";
        description = ''
          File disko reads the LUKS passphrase from at install time instead of
          prompting. Upload it with nixos-anywhere
          (--disk-encryption-keys <local-file> <this path>).
        '';
      };
      tpmPreSeal = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          At install time, seal the volume key to the TPM with no PCR binding,
          so the very first boot needs no passphrase. Only useful on a machine
          that has (or will have) a TPM; the unbound slot is meant to be
          replaced later by a measured-boot keyslot.
        '';
      };
      luksDevice = lib.mkOption {
        type = lib.types.str;
        readOnly = true;
        default = "/dev/disk/by-partlabel/disk-${diskName}-storage";
        description = ''
          Stable /dev path of the LUKS2 container, for keyslot tooling
          (systemd-cryptenroll, cryptsetup) that has to name it unambiguously.
        '';
      };
      measuredBoot = lib.mkOption {
        type = lib.types.bool;
        default = config.boot.lanzaboote.enable or false;
        description = ''
          Bind the LUKS keyslot to lanzaboote's measured-boot (systemd-pcrlock)
          policy over PCRs 0/4/7 and replace the install-time TPM pre-seal with
          it once Secure Boot is active. Defaults to on whenever lanzaboote
          (the `system/secure-boot` module) is enabled, because an unpinned
          keyslot is weaker.

          Turn this off on a machine with no TPM2 (or no EFI event log):
          systemd-pcrlock then runs inside lzbt on every activation and a
          failure aborts the switch/install.
        '';
      };
    };

    config = lib.mkMerge [
      {
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
                  type = "luks";
                  name = luksName;
                  # Non-interactive install: disko reads the passphrase from this
                  # file instead of prompting. It is uploaded by nixos-anywhere
                  # (see README "Install with nixos-anywhere") and is normally a
                  # sops secret, so the same key can be recovered later. At boot
                  # the passphrase is prompted for (or, normally, replaced by the
                  # TPM keyslot).
                  passwordFile = cfg.luksPassphraseFile;
                  settings = {
                    # Let trims through to the backing device (see fstrim
                    # below). This reveals which blocks are in use to the layer
                    # underneath (qcow2, SSD) — acceptable here, and what keeps a
                    # VM image from growing monotonically.
                    allowDiscards = true;
                    # Unlock tokens for the initrd's crypttab entry. The
                    # kernel-side modules come from availableKernelModules below;
                    # FIDO2 support (libcryptsetup-token-systemd-fido2.so + udev
                    # fido_id rules) comes from boot.initrd.systemd.fido2, which
                    # defaults to true because pkgs.systemd has withFido2.
                    #   - tpm2-device=auto: TPM keyslot, enrolled by the host's
                    #     provisioning (measured boot / pcrlock).
                    #   - fido2-device=auto: optional hardware-token keyslot.
                    # Both are harmless with no token/keyslot enrolled:
                    # systemd-cryptsetup falls back to the passphrase prompt.
                    # Keep --tpm2-pcrs explicit at enrollment: its default
                    # changed across systemd versions.
                    crypttabExtraOpts = ["tpm2-device=auto" "fido2-device=auto"];
                  };
                  # Prep the volume for an unattended first boot. Secure Boot is
                  # not active yet, so a PCR 7 seal now would bind to the
                  # "unverified" firmware state and be useless afterwards; seal
                  # to the TPM alone instead, to be replaced by a measured-boot
                  # keyslot once Secure Boot is up.
                  postCreateHook = lib.optionalString cfg.tpmPreSeal ''
                    LUKS_DEV=${lib.escapeShellArg cfg.luksDevice}
                    PASS_FILE=${lib.escapeShellArg cfg.luksPassphraseFile}
                    # The kexec'd installer may not have probed the TPM yet.
                    if [ ! -e /dev/tpmrm0 ]; then
                      /run/current-system/sw/bin/modprobe tpm_crb 2>/dev/null || true
                      for _ in $(seq 1 20); do [ -e /dev/tpmrm0 ] && break; sleep 0.1; done
                    fi
                    if [ -e /dev/tpmrm0 ]; then
                      # The passphrase is used newline-stripped when the
                      # container is formatted; match that or the unlock fails.
                      tr -d '\n' < "$PASS_FILE" > "$PASS_FILE.trimmed"
                      systemd-cryptenroll --unlock-key-file="$PASS_FILE.trimmed" \
                        --tpm2-device=auto --tpm2-pcrs= "$LUKS_DEV" \
                        || echo "WARNING: TPM pre-seal failed; the first boot will ask for the passphrase"
                      rm -f "$PASS_FILE.trimmed"
                    else
                      echo "no TPM device: the first boot will ask for the passphrase"
                    fi
                  '';
                  # disko generates the boot.initrd.luks.devices entry; with the
                  # systemd initrd it becomes a crypttab entry unlocked by
                  # systemd-cryptsetup before anything mounts. passwordFile is
                  # only read while formatting/mounting at install time and is
                  # not part of the installed system's config.
                  content = {
                    type = "btrfs";
                    extraArgs = ["-L" "storage" "-f"];
                    subvolumes = {
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
                      # Separate subvolume for the hibernation swapfile:
                      # mounting it with nodatacow means the file needs no +C
                      # chattr and is never compressed (both would waste CPU on
                      # a large swapfile), and keeping it out of `persistent`
                      # means a future `btrfs subvolume snapshot /persistent`
                      # stays small.
                      "swap" = {
                        mountpoint = "/persistent/swap";
                        mountOptions = ["nodatacow" "noatime"];
                      };
                    };
                    # root-blank is NOT declared as a subvolume: it is created
                    # here as a READONLY snapshot of the still-empty root
                    # subvolume, so the pristine state the initrd rolls back to
                    # can never drift. (-r matters: a writable blank would
                    # silently accumulate any change made through a future
                    # mistake in the rollback script.)
                    postCreateHook = ''
                      MNTPOINT=$(mktemp -d)
                      mount -t btrfs -o subvol=/ /dev/mapper/${luksName} "$MNTPOINT"
                      trap 'umount "$MNTPOINT"; rm -rf "$MNTPOINT"' EXIT
                      btrfs subvolume snapshot -r "$MNTPOINT"/root "$MNTPOINT"/root-blank
                    '';
                  };
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

        # The TPM must be up in the initrd before systemd-cryptsetup tries the
        # tpm2-device=auto token (stage 2 gets tpm_tis/tpm_crb from the host's
        # provisioning, or add them there if it has no such module).
        boot.initrd.availableKernelModules = ["tpm_tis" "tpm_crb"];

        # Hibernation: swapfile on the `swap` subvolume (see swapSize), inside
        # the LUKS container. boot.resumeDevice is deliberately NOT set: it
        # would add `resume=` to the kernel command line, and
        # systemd-hibernate-resume prefers that over the HibernateLocation EFI
        # variable while defaulting resume_offset to 0 (the start of the
        # partition, not the swap file's header), so resuming silently fails
        # ("Unable to resume ... offset 0, continuing boot process") and even
        # hibernating is refused as ESTALE. Instead systemd-sleep records the
        # image location — the block device's filesystem UUID and the swap
        # file's page offset, computed through FIEMAP (btrfs has its own
        # lookup) — in HibernateLocation, and the initrd generator uses it only
        # when resume= is absent, writing /sys/power/resume{,_offset} before
        # local-fs-pre.target. /dev/mapper/${luksName} only exists after the
        # initrd unlock; the resume unit is bound to that device's unit, so
        # ordering resolves through cryptsetup automatically.
        swapDevices = [
          {
            device = "/persistent/swap/swapfile";
            size = cfg.swapSize;
          }
        ];

        services.btrfs.autoScrub = {
          enable = true;
          interval = "monthly";
        };

        # btrfs frees space via periodic fstrim, not automatic discards; with
        # allowDiscards on the LUKS container those trims punch through to the
        # underlying device.
        services.fstrim.enable = true;

        boot.initrd.systemd.services.rollback = {
          description = "Roll back the btrfs root subvolume to a pristine snapshot";
          wantedBy = ["initrd.target"];
          # HIBERNATION-SAFE ordering (Discourse 39955, systemd PR #26348):
          # systemd-hibernate-resume@.service is ordered Before=local-fs-pre.target
          # (bootup(7)), so by ordering this service After=local-fs-pre.target
          # the resume check ALWAYS completes first. On a resume boot the kernel
          # swaps the hibernated image back in and the initrd - this service
          # included - is discarded before we ever start; on a normal boot there
          # is no image, the resume unit continues immediately, and the rollback
          # then runs. Without this the rollback races the resume and corrupts
          # the filesystem the hibernated kernel is about to write to.
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
            mount -t btrfs -o subvol=/ /dev/mapper/${luksName} /mnt

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
        # ssh host keys, sops keys, logs, ... on each boot. Requiring the
        # module keeps that from silently producing a stateless system (and the
        # /persistent/var/lib/auto-cryptenroll entry below pointless).
        #
        # Measured boot likewise only makes sense with lanzaboote. Both fail
        # the evaluation instead of a deployment/reboot.
        assertions = [
          {
            assertion = config.modules.preservation.enable or false;
            message = ''
              modules.diskLayouts.luksBtrfs wipes the btrfs root at every boot
              and expects durable state to be bind-mounted from /persistent.
              Resolve "preservation" and set modules.preservation.enable = true,
              or use a layout that keeps / (e.g. "disk-layouts/ext4").
            '';
          }
          {
            assertion = !cfg.measuredBoot || (config.boot.lanzaboote.enable or false);
            message = ''
              modules.diskLayouts.luksBtrfs.measuredBoot is enabled but
              lanzaboote is not: enable "system/secure-boot", or set
              modules.diskLayouts.luksBtrfs.measuredBoot = false.
            '';
          }
          {
            assertion = persistentPath == "/persistent";
            message = ''
              modules.diskLayouts.luksBtrfs creates the persistent subvolume
              (and everything that lives on it) at /persistent, but
              modules.preservation.persistentPath is ${persistentPath}.
              Preserved state would bind-mount from a path this layout does
              not create.
            '';
          }
        ];
      }

      # --- Measured boot: TPM policy bound to firmware + boot chain ---
      # PCR 0 (firmware code) + 4 (boot loader and its UKI measurements) + 7
      # (Secure Boot policy): a swapped initrd or kernel no longer matches,
      # which the static PCR 7 binding alone could not detect. lzbt regenerates
      # the policy on every install/rebuild, so nothing has to be re-enrolled
      # after an update.
      #
      # autoCryptenroll waits for Secure Boot (ConditionSecurity=
      # uefi-secureboot, because autoEnrollKeys is on), unlocks with the
      # install-time TPM pre-seal (--unlock-tpm2-device=auto), wipes every
      # TPM2 slot (--wipe-slot=tpm2) and enrolls the pcrlock-bound one, then
      # reboots (autoReboot) so the next boot measures the installed
      # artifacts. It therefore needs an existing TPM2 keyslot: the pre-seal
      # from `tpmPreSeal` above, which survives on this layout. Without one the
      # unit fails and the passphrase remains the fallback.
      #
      # The policy and the per-generation components live DIRECTLY on the
      # persistent subvolume (non-default paths, so preservation is not
      # involved).
      #
      # This is load-bearing: systemd-pcrlock reuses the NV index, SRK and PIN
      # blobs from the *previous* policy file when it regenerates one ("When we
      # update the policy the old serializations for NV, SRK, PIN remain the
      # same", pcrlock.c). The LUKS token is bound to those blobs, and the
      # initrd only accepts a policy credential whose SRK/NV match the token.
      # With the policy on the wiped root, every regeneration (install, every
      # switch, every boot) minted a fresh NV index, so after any rebuild the
      # token no longer matched the credential lzbt writes to the ESP and the
      # initrd fell back to the passphrase prompt. Persisting the file keeps
      # the NV index stable and updates the PCR predictions in place.
      #
      # (Do NOT use preservation's `files` for this: its file mode also creates
      # an empty file at the volatile path, and systemd-pcrlock refuses to
      # parse an empty policy — that broke nixos-install's bootloader step.)
      # `optionalAttrs` guarded on option existence, not mkIf: nixpkgs checks
      # definitions for unknown option paths *before* discharging a false
      # `mkIf` condition, so a host without lanzaboote would still be rejected
      # for naming boot.lanzaboote. The guard must read `options` only — reading
      # `config` there recurses while modules are being pushed down.
      (lib.optionalAttrs (options ? boot.lanzaboote.enable) {
        boot.lanzaboote.measuredBoot = lib.mkIf cfg.measuredBoot {
          enable = true;
          pcrs = [0 4 7];
          pcrlockPolicy = persistentPath + "/var/lib/systemd/pcrlock.json";
          pcrlockDirectory = persistentPath + "/var/lib/pcrlock.d";
          autoCryptenroll = {
            enable = true;
            device = cfg.luksDevice;
            autoReboot = true;
          };
        };

        # /dev/tpmrm0 must exist in stage 2, not just the initrd
        # (availableKernelModules above covers the unlock itself);
        # systemd-pcrlock and systemd-cryptenroll both need it.
        boot.kernelModules = lib.mkIf cfg.measuredBoot ["tpm_tis" "tpm_crb"];

        systemd.tmpfiles.rules = lib.mkIf cfg.measuredBoot [
          "d ${persistentPath}/var/lib/pcrlock.d 0700 root root - -"
          "d ${persistentPath}/var/lib/systemd 0755 root root - -"
          "d ${persistentPath}/var/lib/auto-cryptenroll 0700 root root - -"
        ];
      })

      # Marker that the TPM2 keyslot is already enrolled.
      (lib.optionalAttrs (options ? preservation.preserveAt) {
        preservation.preserveAt.${persistentPath}.directories = lib.mkIf cfg.measuredBoot [
          {directory = "/var/lib/auto-cryptenroll";}
        ];
      })
    ];
  };
}
