# dots

Ben's somewhat fancy Nix config.

Secrets are managed with [sops-nix](https://github.com/Mic92/sops-nix) using
post-quantum age keys; encrypted files live in `secrets/`. New machines are
installed with [nixos-anywhere](https://github.com/nix-community/nixos-anywhere)
+ [disko](https://github.com/nix-community/disko) in one command.

## Secrets

Recipients are defined in `.sops.yaml`:

- `secrets/common.yaml` — admin keys + all hosts
- `secrets/hosts/<host>.yaml` — admin keys + that host only

There are two admin keys: a software PQ age key
(`~/.config/sops/age/keys.txt`, recovery) and a hardware-backed one living on
Ben's YubiKey (fido2-hmac: the key is derived fresh from the token on every
decryption and never persists — see `age-plugin-fido2-hmac`). Hosts decrypt
with their own PQ age key at `/var/lib/sops-nix/key.txt`.

Edit secrets (any NixOS host; insert the YubiKey and enter its PIN when
prompted — the token is only needed if you decrypt with it):

```bash
nix shell nixpkgs#sops nixpkgs#age nixpkgs#age-plugin-fido2-hmac \
  -c sops secrets/common.yaml
```

### YubiKey admin key

Generate the identity once (`-n -pq` makes the recipient a PQ hybrid; answer
"yes" to requiring a PIN for decryption):

```bash
nix shell nixpkgs#age-plugin-fido2-hmac -c age-plugin-fido2-hmac -n -pq -g
```

Append the printed `AGE-PLUGIN-FIDO2-HMAC-...` identity to
`~/.config/sops/age/keys.txt`, then add the `age1fido2-hmac1...` recipient as
`&admin_fido2` in `.sops.yaml` and run `sops updatekeys secrets/*.yaml`.

Notes:

- The identity stub alone is useless without the token (and the PIN), but keep
  it out of the repo anyway (`keys.txt` is already gitignored).
- Losing the token is survivable via the software admin key; the credential
  cannot be cloned to a second token, so the software key is the backup.
- The software key must stay in `keys.txt` alongside it: with it removed,
  `sops updatekeys` would leave secrets decryptable only while the token
  exists.

## Daily use

```bash
./bootstrap.sh <host> [switch|boot|test]
```

If `~/.config/sops/age/hosts/<host>.key` is missing, the script generates it,
installs it to `/var/lib/sops-nix/key.txt`, and prints the recipient to add to
`.sops.yaml` (then `sops updatekeys secrets/common.yaml` and re-run). If the
host is already registered in `.sops.yaml`, it refuses to generate a new key.

## New machine

### 1. Add the host to the repo

```text
machines/<host>/<host>.nix                   # host module; required
machines/<host>/hardware-configuration.nix   # optional; generated during install
```

Any `.nix` under `machines/<host>/` is auto-attached as a nixos module by
`modules/flake-parts/hosts.nix` — no explicit imports. The only exception is
`hardware-configuration.nix`, which stays a raw `nixos-generate-config` module
so nixos-anywhere can overwrite it verbatim.

Pick a disk layout from `modules/disk-layouts/` and set
`modules.diskLayouts.<layout>.device` / `swapSize`:

- `luks-btrfs` (caelum): LUKS2 + btrfs, root rolled back to blank at boot.
  Requires `preservation` enabled. TPM measured boot is automatic; set
  `measuredBoot = false` on machines without a TPM2.
- `luks-zfs`: same shape with a zpool instead of btrfs; swap is a second LUKS
  container because ZFS cannot host a swapfile. Hibernation is on by default
  and still carries OpenZFS's known freeze risk; `hibernation = false` keeps
  the swap for memory pressure only.
- `btrfs` (apus): same as above without LUKS/TPM/Secure Boot, for trusted-host VMs.
- `ext4` (navis): plain ESP + ext4 with optional swapfile; no preservation needed.

Only touch the flake if you add a new input: `git add -N <new-file>`, then
`nix run .#write-flake`.

### 2. Provision the host's sops key

Restore the existing `~/.config/sops/age/hosts/<host>.key`, or generate one:

```bash
nix shell nixpkgs#age -c age-keygen -pq -o ~/.config/sops/age/hosts/<host>.key
```

Add the recipient (`age-keygen -y <file>`) to `.sops.yaml`, re-wrap, and verify
decryption **before** installing — without this key the system has no user
password:

```bash
nix shell nixpkgs#sops nixpkgs#age -c sops updatekeys secrets/common.yaml
SOPS_AGE_KEY_FILE=~/.config/sops/age/hosts/<host>.key \
  nix shell nixpkgs#sops nixpkgs#age -c sops -d secrets/common.yaml > /dev/null && echo OK
```

### 3. Install

Boot the target from a NixOS minimal ISO, set a root password, start sshd, then:

```bash
tmp=$(mktemp -d)
install -Dm600 ~/.config/sops/age/hosts/<host>.key "$tmp/persistent/var/lib/sops-nix/key.txt"
nix run nixpkgs#nixos-anywhere -- \
  --generate-hardware-config nixos-generate-config machines/<host>/hardware-configuration.nix \
  --extra-files "$tmp" --flake .#<host> root@<target-ip>
```

`--generate-hardware-config` writes the hardware configuration into the repo
during the install (drop it on re-runs). `--extra-files` stages the sops key.

**LUKS hosts** also need the passphrase from sops (disko never prompts):

```bash
nix shell nixpkgs#sops nixpkgs#age \
  -c sops -d --output-type json secrets/hosts/<host>.yaml \
  | nix shell nixpkgs#jq -c jq -rj '.["luks-passphrase"]' > "$tmp/luks-passphrase"

nix run nixpkgs#nixos-anywhere -- \
  --extra-files "$tmp" \
  --disk-encryption-keys /tmp/luks-passphrase "$tmp/luks-passphrase" \
  --flake .#<host> root@<target-ip>
```

`disko` wipes the target disk without asking. Validate first:

```bash
nix build .#nixosConfigurations.<host>.config.system.build.toplevel
nix build .#nixosConfigurations.<host>.config.system.build.diskoScript
nix run nixpkgs#nixos-anywhere -- --vm-test --flake .#<host>   # unencrypted layouts only
```

### 4. First boot

LUKS hosts set themselves up over three unattended boots: Secure Boot key
generation + reboot, key enrollment + TPM pcrlock (PCRs 0/4/7) + reboot, then
measured-boot-only unsealing. Verify with:

```bash
bootctl status                                        # Secure Boot: enabled
cryptsetup luksDump /dev/disk/by-partlabel/disk-main-storage | grep -i tpm2
```

Then copy the host key onto the machine and finish the switch:

```bash
scp <admin-machine>:~/.config/sops/age/hosts/<host>.key ~/.config/sops/age/hosts/
./bootstrap.sh <host>
```

Reboot once and confirm: journals persist (`journalctl -b -1`), ssh host keys
don't change, and anything not declared is gone.

### FIDO2 unlock (optional, caelum)

A FIDO2 token adds a hardware unlock path independent of PCRs (an alternative
to the TPM slot, not an extra factor). With the token passed through to the
guest, enroll via a marker file:

```bash
sudo touch /persistent/.enroll-fido2
sudo systemctl restart caelum-provision    # touch the token when it blinks
```
