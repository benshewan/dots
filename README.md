# dots

Ben's somewhat fancy Nix config

## Secrets

Secrets are managed by [sops-nix](https://github.com/Mic92/sops-nix) with
post-quantum age keys (hybrid X25519 + ML-KEM-768). Encrypted secrets live in
this repo under `secrets/`, so there is no separate private repo.

Recipient rules are in `.sops.yaml`:

- `secrets/common.yaml` — admin key + both hosts
- `secrets/hosts/<host>.yaml` — admin key + that host only

### Keys

Each host decrypts with its own PQ age identity at `/var/lib/sops-nix/key.txt`.
The admin key lives at `~/.config/sops/age/keys.txt` and is only needed to edit
secrets. It is never committed.

Generate them once (`age` from nixpkgs):

```bash
nix shell nixpkgs#age -c age-keygen -pq -o ~/.config/sops/age/keys.txt
nix shell nixpkgs#age -c age-keygen -pq -o ~/.config/sops/age/hosts/navis.key
nix shell nixpkgs#age -c age-keygen -pq -o ~/.config/sops/age/hosts/caelum.key
```

Add each public key (`age-keygen -y <file>`) as a recipient in `.sops.yaml`,
then run `sops updatekeys secrets/*.yaml`.

### Editing secrets

```bash
nix shell nixpkgs#sops nixpkgs#age -c sops secrets/common.yaml
```

### Bootstrapping a host

```bash
./bootstrap.sh navis
```

If `~/.config/sops/age/hosts/navis.key` does not exist, the script generates a
new PQ key with `age-keygen -pq`, installs it to `/var/lib/sops-nix/key.txt`,
and prints the recipient to add to `.sops.yaml`. Add it to the relevant
`creation_rules`, run `sops updatekeys secrets/common.yaml`, then re-run the
script. If the host is already registered in `.sops.yaml`, the script refuses to
generate a new key (it would not decrypt the existing secrets).

Replace `navis` with the target host (`caelum`, `navis`, ...). Optional second
arg: `switch` (default), `boot`, or `test`.

## Setting up a new machine

New hosts are provisioned from scratch with
[nixos-anywhere](https://github.com/nix-community/nixos-anywhere) + [disko](https://github.com/nix-community/disko):
one command partitions the disk, installs NixOS, and reboots into a fully
configured system. Existing machines (with a NixOS system already running) can
skip straight to `./bootstrap.sh <host>` instead.

### 1. Add the host to the repo

```text
machines/<host>/<host>.nix                   # host module: resolve list, hostMeta, tweaks
machines/<host>/hardware-configuration.nix   # optional; generated during install (step 3)
```

`machines/<host>/<host>.nix` is a flake-parts module registering itself as
`flake.modules.nixos."hosts/<host>"`. Any other `.nix` file under
`machines/<host>/` is a flake-parts module registering as
`flake.modules.nixos."machines/<host>/<name>"`; both are attached to the host
automatically by `modules/flake-parts/hosts.nix` — no explicit imports
anywhere. One exception: `hardware-configuration.nix` stays a raw
nixos-generate-config module (so nixos-anywhere can overwrite it verbatim);
`hosts.nix` imports it by path, and the import-tree scan skips it.

A brand-new host needs only `<host>.nix`: the hardware configuration does not
have to exist up front, because nixos-anywhere generates it on the target
during the install (see step 3). Note `--vm-test` cannot run before the
hardware configuration exists — it rehearses a locally built system and there
is nothing to query yet; run it after the install once the file is committed.

- Reuse a layout from `modules/disk-layouts/` instead of writing one per host:
  - `luks-btrfs` (used by `caelum`): GPT + LUKS2 + btrfs with `root` /
    `root-blank` / `nix` / `persistent` subvolumes, rolled back to blank at
    every boot. Hosts set `modules.diskLayouts.luksBtrfs.device` and `swapSize`.
  - `btrfs` (new for `apus`): unencrypted GPT + ESP + btrfs with wiped `root` /
    `root-blank` / `nix` / `persistent` subvolumes — caelum's `luks-btrfs`
    layout without LUKS, TPM or Secure Boot, for hosts whose threat model does
    not include physical disk access (e.g. VMs on a trusted host). Requires
    `preservation` to be resolved and enabled (asserted). Hosts set
    `modules.diskLayouts.btrfs.device` and `swapSize` (null = no swap; no
    hibernation support).
  - `ext4`: plain unencrypted ESP + ext4 root with an optional `/swapfile`
    (no swap partition; `swapSize` is in MiB and `null` disables swap), the
    scheme of a stock `nixos-generate-config` install (`navis` runs such a
    disk, but it was partitioned by hand and is not managed by disko). Hosts
    set `modules.diskLayouts.ext4.device` / `swapSize`.
- If a `luks-btrfs` host also resolves `system/secure-boot`, the layout enables
  lanzaboote measured boot (systemd-pcrlock over PCRs 0/4/7) and auto-enrolls
  the measured TPM keyslot. On a machine without a TPM2 (or without an EFI
  event log) set `modules.diskLayouts.luksBtrfs.measuredBoot = false`: pcrlock
  runs during every activation and a failure aborts the switch/install.
- Shortcut: on a fresh host there is no hardware configuration yet. Pass
  `--generate-hardware-config nixos-generate-config machines/<host>/hardware-configuration.nix`
  and nixos-anywhere fills that gap itself: after kexec it runs
  `nixos-generate-config --show-hardware-config --no-filesystems` on the real
  hardware, writes the file into the repo, `git add -N`s it, and only then
  builds the flake — so one command takes an unknown machine from ISO to
  installed system. (The flake must reference the path, which `<host>.nix`
  does not need to do: `hosts.nix` attaches it automatically.)
- With `luks-btrfs` the host module must also resolve `"preservation"` and
  enable `modules.preservation.enable` (the layout asserts this: without it
  the root rollback would silently throw away all state every boot). Anything that needs to survive a
  reboot is added to `preservation.preserveAt."/persistent"` (or as a
  `preservation/<feature>` companion next to its feature module — `resolve`
  picks those up automatically). The `ext4` layout needs neither.
- Only touch the flake if you add a new input: `git add -N <new-file>` first,
  then `nix run .#write-flake` (it only sees files git knows about).

Validate the config without touching any disk:

```bash
nix build .#nixosConfigurations.<host>.config.system.build.toplevel
nix build .#nixosConfigurations.<host>.config.system.build.diskoScript
nix run nixpkgs#nixos-anywhere -- --vm-test --flake .#<host>   # full dry run in a VM
```

LUKS hosts (caelum) cannot use `--vm-test`: nixos-anywhere rejects
`--disk-encryption-keys` together with it, and nothing supplies disko's
`passwordFile` inside the test VM. For those, the two builds above are the dry
run; the disk passphrase is uploaded in step 3. Unencrypted layouts
(`disk-layouts/ext4`) can be exercised with `--vm-test`.

### 2. Provision the host's sops key

Secrets only decrypt with the host's own PQ age identity. Restore the existing
`~/.config/sops/age/hosts/<host>.key`, or generate a new one:

```bash
nix shell nixpkgs#age -c age-keygen -pq -o ~/.config/sops/age/hosts/<host>.key
```

Add the recipient (`age-keygen -y <file>`) under `keys:` and to the relevant
`creation_rules` in `.sops.yaml`, re-wrap, and verify decryption **before**
installing — without this key the new system has no user password at all:

```bash
nix shell nixpkgs#sops nixpkgs#age -c sops updatekeys secrets/common.yaml
SOPS_AGE_KEY_FILE=~/.config/sops/age/hosts/<host>.key \
  nix shell nixpkgs#sops nixpkgs#age -c sops -d secrets/common.yaml > /dev/null && echo OK
```

If you add a host-specific secrets file later (`secrets/hosts/<host>.yaml`),
run `sops updatekeys` on it too after adding the recipient.

If a host is already registered in `.sops.yaml` and its key is lost, remove its
recipient first, rotate, and `sops updatekeys` — a regenerated key cannot
decrypt the old ciphertext.

### 3. Install with nixos-anywhere

Boot the target from a NixOS minimal ISO, set a root password (or authorized
key) and start sshd, then from a machine that has this repo:

```bash
tmp=$(mktemp -d)
install -Dm600 ~/.config/sops/age/hosts/<host>.key "$tmp/persistent/var/lib/sops-nix/key.txt"
nix run nixpkgs#nixos-anywhere -- \
  --generate-hardware-config nixos-generate-config machines/<host>/hardware-configuration.nix \
  --extra-files "$tmp" --flake .#<host> root@<target-ip>
```

`--generate-hardware-config` is what makes a completely fresh host work: after
kexec the generator runs on the real hardware and writes
`machines/<host>/hardware-configuration.nix` into the repo before the flake is
evaluated. Drop the flag on re-runs (the file already exists, and overwriting
it on a working machine is still safe but pointless).

`--extra-files` copies its contents onto the target's root `/` as-is, so the
key is staged under `persistent/var/lib/sops-nix/` (where the bind-mounted
`/var/lib/sops-nix` actually lives). Without it the new system has no sops key
and no user password.

Encrypted layouts (caelum) additionally take their LUKS passphrase from the
`luks-passphrase` sops secret, so disko never prompts and no passphrase has to
be typed in later either:

```bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
tmp=$(mktemp -d)
install -Dm600 ~/.config/sops/age/hosts/<host>.key "$tmp/persistent/var/lib/sops-nix/key.txt"

# sops -d prints YAML; ask for JSON so jq can read it. The key name contains a
# hyphen, so it needs ["..."] quoting in the jq filter.
nix shell nixpkgs#sops nixpkgs#age \
  -c sops -d --output-type json secrets/hosts/<host>.yaml \
  | nix shell nixpkgs#jq -c jq -rj '.["luks-passphrase"]' > "$tmp/luks-passphrase"
[ "$(wc -c < "$tmp/luks-passphrase")" -gt 0 ]   # never format with an empty key

nix run nixpkgs#nixos-anywhere -- \
  --extra-files "$tmp" \
  --disk-encryption-keys /tmp/luks-passphrase "$tmp/luks-passphrase" \
  --flake .#<host> root@<target-ip>
```

(`--disk-encryption-keys` takes the remote path first; the file is in the
installer environment before disko runs, which is where `passwordFile` in
`modules/disk-layouts/luks-btrfs.nix` points.)

`disko` wipes the target disk without asking; on unencrypted hosts run the
`--vm-test` rehearsal from step 1 first if the layout is unproven.

### 4. First boot

On a LUKS host nothing has to be typed: disko pre-sealed the volume key to the
TPM (no PCR binding), and from then on the system finishes its own setup in
three boots:

1. boot 1 — lanzaboote generates the Secure Boot keys and prepares them for
   enrollment, then reboots itself (`boot.lanzaboote.autoEnrollKeys.autoReboot`);
2. boot 2 — the firmware enrolls the keys, so this boot runs with Secure Boot
   active; `auto-cryptenroll` replaces every TPM2 keyslot with one bound to a
   systemd-pcrlock policy over PCRs 0/4/7 (measured boot) and reboots itself;
   `caelum-provision` adds the sops recovery passphrase keyslot;
3. boot 3 onward — the volume unseals only for the measured boot chain.

```bash
journalctl -u generate-sb-keys -u prepare-sb-auto-enroll -u auto-cryptenroll \
  -u caelum-provision -b
bootctl status          # Secure Boot: enabled
systemd-pcrlock is-supported                    # yes
cryptsetup luksDump /dev/disk/by-partlabel/disk-main-storage | grep -i tpm2
```

Measured boot costs generations on the ESP: `boot.lanzaboote.configurationLimit`
must stay at 4 (systemd-pcrlock's PCR 4 variant limit; lanzaboote asserts it).

The initrd rolls the root subvolume back to blank, so the system comes up
exactly as declared. Check that state survived and finish the switch:

```bash
ssh <user>@<target-ip>
# in the ssh session:
findmnt | grep persistent     # bind mounts from /persistent
ls /persistent/var/lib/sops-nix/key.txt
```

Still on the new machine, copy the host key into its home so `bootstrap.sh`
can verify it against `/var/lib/sops-nix/key.txt`, then finish the switch:

```bash
mkdir -p ~/.config/sops/age/hosts
scp <admin-machine>:~/.config/sops/age/hosts/<host>.key ~/.config/sops/age/hosts/
./bootstrap.sh <host>
```

(`<admin-machine>` is wherever the host key currently lives — e.g. the machine
you generated it on in step 2.)

Then reboot once more and confirm: journals persist (`journalctl -b -1`),
ssh host keys don't change, and anything you did *not* declare is gone.

### 5. Optional: FIDO2 token unlock (caelum)

The TPM keyslot is bound to PCR 7, so a firmware update or a lost swtpm state
leaves only the passphrase. A FIDO2 token adds a hardware unlock path that is
independent of PCRs. LUKS keyslots are OR-ed, so it is an alternative, not an
extra factor on the TPM slot.

Give the VM the token (host USB passthrough; `lsusb` to find it) and enroll
from inside the guest:

```bash
# host, VM shut down
virt-xml nixos-25.11 --add-device --host-device <vendor>:<product>
# guest, token attached
sudo touch /persistent/.enroll-fido2
sudo systemctl restart caelum-provision    # then touch the token when it blinks
```

`crypttabExtraOpts` in `modules/disk-layouts/luks-btrfs.nix` already carries
`fido2-device=auto`, so the initrd offers the token at the next boot. Enrollment is opt-in through that
marker file because it needs a physical touch (and the unit would otherwise
wait for a token on every boot); the marker is deleted once the keyslot exists.
