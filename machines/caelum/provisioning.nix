# Post-install provisioning for caelum's encrypted disk.
#
# The disk setup itself lives in modules/disk-layouts/luks-btrfs.nix: it
# formats the LUKS container without prompting (the passphrase is the
# `luks-passphrase` secret, uploaded by nixos-anywhere), pre-seals the volume
# key to the VM's TPM with no PCR binding so even the first boot needs no
# passphrase, and — because this host also loads system/secure-boot — enables
# lanzaboote's measured boot so auto-cryptenroll replaces that pre-seal with a
# systemd-pcrlock keyslot over PCRs 0/4/7 once Secure Boot is active. Do not
# add a static `--tpm2-pcrs=` slot back: it would unlock first and only check
# the Secure Boot policy, not the kernel/initrd.
#
# What is left for this unit (all needs the *running* installed system):
#
#   1. Optionally enroll a FIDO2 hardware token, requested by creating
#      `.enroll-fido2` in the persistent subvolume (see the inline comment): an
#      *alternative* unlock path that does not depend on PCR state.
#   2. Enroll `luks-recovery-key` from sops (secrets/hosts/caelum.yaml) as an
#      independent LUKS keyslot: the backup pass key typed at the initrd
#      prompt if the TPM and the main passphrase both fail. Retrieve it with
#      `sops -d secrets/hosts/caelum.yaml` on a machine holding an admin key.
#
# The `luks-passphrase` secret authorizes the keyslot changes, so the unit is
# unattended (except the physical token touch). It runs on every boot and only
# logs once there is nothing to do. Re-run: sudo systemctl restart caelum-provision
{
  config,
  lib,
  pkgs,
  ...
}: let
  # The LUKS2 container the shared layout creates
  # (modules/disk-layouts/luks-btrfs.nix).
  luksDev = config.modules.diskLayouts.luksBtrfs.luksDevice;
in {
  # FIDO2 unlocking happens in the initrd (crypttab fido2-device=auto, set in
  # modules/disk-layouts/luks-btrfs.nix). The token library, libfido2 and the
  # hidraw udev rules are only added to the initrd when this is on. It already
  # defaults to boot.initrd.systemd.package.withFido2 (true for pkgs.systemd);
  # pin it so a package change cannot silently drop the token support.
  boot.initrd.systemd.fido2.enable = true;

  # --- LUKS key material (sops-encrypted in the repo, tmpfs-only at runtime) ---
  sops.secrets = {
    # The passphrase typed at the initrd prompt. Also the install-time key, and
    # what authorizes the keyslot changes below.
    "luks-passphrase" = {
      sopsFile = ../../secrets/hosts/caelum.yaml;
      mode = "0400";
    };
    # The backup pass key: a second, independent LUKS passphrase.
    "luks-recovery-key" = {
      sopsFile = ../../secrets/hosts/caelum.yaml;
      mode = "0400";
    };
  };

  systemd.services.caelum-provision = {
    description = "Enroll the optional FIDO2 token and the sops recovery keyslot";
    wantedBy = ["multi-user.target"];
    after = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = with pkgs; [systemd cryptsetup jq coreutils];
    script = ''
      set -uo pipefail
      LUKS_DEV=${lib.escapeShellArg luksDev}
      PASS_FILE=/run/secrets/luks-passphrase
      RECOVERY_FILE=/run/secrets/luks-recovery-key
      RECOVERY_FLAG=${config.modules.preservation.persistentPath}/.luks-recovery-enrolled

      log() { echo "[caelum-provision] $*"; }
      fail=0

      if ! cryptsetup isLuks "$LUKS_DEV" 2>/dev/null; then
        log "ERROR: $LUKS_DEV is not a LUKS container"
        exit 1
      fi

      # Keyslot changes are driven by this machine-readable dump; if it is not
      # available, stop rather than re-enrolling (and piling up) slots blind.
      if ! cryptsetup luksDump --dump-json-metadata "$LUKS_DEV" >/dev/null 2>&1; then
        log "ERROR: cannot read LUKS metadata as JSON; refusing to modify keyslots"
        exit 1
      fi

      # Keyslots holding a systemd-tpm2 token bound to a systemd-pcrlock
      # policy (lanzaboote's measured boot, enabled by the shared layout when
      # lanzaboote is in use).
      pcrlock_slots() {
        cryptsetup luksDump --dump-json-metadata "$LUKS_DEV" |
          jq -r '(.tokens // {})[] | select(.type == "systemd-tpm2")
                 | select((.["tpm2_pcrlock"] // .["tpm2-pcrlock"]) == true)
                 | .keyslots[]'
      }

      # sops secrets may or may not end with a newline; keyslots are created
      # from the newline-stripped value (disko does the same with echo -n), so
      # trim before using it to unlock.
      trim() { tr -d '\n' < "$1" > "$2" && chmod 0600 "$2"; }

      # --- 1. FIDO2 keyslot (opt-in: a hardware token cannot be enrolled
      # unattended, systemd-cryptenroll waits for a physical touch) ---
      # Plug the token in (libvirt: host USB passthrough), then touch
      # `$FIDO2_FLAG` and restart this unit.
      # The marker is deleted on success. The resulting keyslot is an
      # ALTERNATIVE to the TPM one (LUKS unlocks with any single keyslot), for
      # when the pcrlock policy no longer matches — firmware update, swtpm
      # state lost — without falling back to the passphrase.
      FIDO2_FLAG=${config.modules.preservation.persistentPath}/.enroll-fido2
      fido2_slots() {
        cryptsetup luksDump --dump-json-metadata "$LUKS_DEV" |
          jq -r '(.tokens // {})[] | select(.type == "systemd-fido2")
                 | .keyslots[]'
      }

      if [ -n "$(fido2_slots)" ]; then
        rm -f "$FIDO2_FLAG"
        log "FIDO2 keyslot already enrolled"
      elif [ ! -f "$FIDO2_FLAG" ]; then
        log "no FIDO2 request (create $FIDO2_FLAG with a token attached to enroll one)"
      elif [ ! -f "$PASS_FILE" ]; then
        log "sops secret luks-passphrase not materialized; cannot enroll FIDO2"
      else
        trim "$PASS_FILE" /run/luks-pass.tmp
        log "enrolling a FIDO2 keyslot — TOUCH THE TOKEN when it blinks"
        # Defaults: user presence required (the touch), no client PIN, no user
        # verification. Add --fido2-with-client-pin=yes for token+PIN unlock.
        if timeout 300 systemd-cryptenroll --unlock-key-file=/run/luks-pass.tmp \
          --fido2-device=auto "$LUKS_DEV"; then
          rm -f "$FIDO2_FLAG"
          log "FIDO2 keyslot enrolled"
        else
          log "FIDO2 enrollment failed (no token attached, or no touch); marker kept"
          fail=1
        fi
        rm -f /run/luks-pass.tmp
      fi

      # --- 2. Recovery keyslot from sops ---
      if [[ -f "$RECOVERY_FLAG" ]]; then
        log "recovery keyslot already enrolled"
      elif [[ ! -f "$RECOVERY_FILE" || ! -f "$PASS_FILE" ]]; then
        log "sops secrets not materialized; skipping the recovery keyslot"
      else
        trim "$PASS_FILE" /run/luks-pass.tmp
        trim "$RECOVERY_FILE" /run/luks-rec.tmp
        log "adding the recovery keyslot from sops"
        cryptsetup luksAddKey "$LUKS_DEV" /run/luks-rec.tmp --key-file /run/luks-pass.tmp \
          && touch "$RECOVERY_FLAG" \
          || fail=1
        rm -f /run/luks-pass.tmp /run/luks-rec.tmp
      fi

      # --- 3. state ---
      # The TPM slot is lanzaboote's auto-cryptenroll (enabled by the shared
      # disk layout), not this unit; report it so the journal shows where the
      # boot stands.
      pcrlock=$([[ -n "$(pcrlock_slots)" ]] && echo yes || echo no)
      fido2=$([[ -n "$(fido2_slots)" ]] && echo yes || echo no)
      recovery=$([[ -f "$RECOVERY_FLAG" ]] && echo yes || echo no)
      log "keyslots: TPM-pcrlock=$pcrlock FIDO2=$fido2 recovery=$recovery"
      if [[ "$pcrlock" == yes && "$recovery" == yes ]]; then
        log "provisioned — the TPM unseals the volume measured-boot-verified"
      elif [[ "$pcrlock" != yes ]]; then
        log "no pcrlock keyslot yet: auto-cryptenroll waits for Secure Boot to be active"
      fi
      exit $fail
    '';
  };
}
