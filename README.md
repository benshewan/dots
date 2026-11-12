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
machines/<host>/hardware-configuration.nix   # kernel/module bits (qemu-guest, etc.)
machines/<host>/disko.nix                    # disk layout + fileSystems
modules/hosts/<host>.nix                     # host module: resolve list, hostMeta, tweaks
```

- Copy the structure from `caelum` (erase-your-darlings: one btrfs partition
  with `root` / `root-blank` / `nix` / `persistent` subvolumes, rolled back to
  blank at every boot) or from `navis`.
- Shortcut: let nixos-anywhere generate the hardware config during the install
  (step 3) with
  `--generate-hardware-config nixos-generate-config machines/<host>/hardware-configuration.nix`.
- The host module must resolve `"disko"` and `"preservation"` and enable
  `modules.preservation.enable`. Anything that needs to survive a reboot is
  added to `preservation.preserveAt."/persistent"` (or as a
  `preservation/<feature>` companion next to its feature module — `resolve`
  picks those up automatically).
- Only touch the flake if you add a new input: `git add -N <new-file>` first,
  then `nix run .#write-flake` (it only sees files git knows about).

Validate the config without touching any disk:

```bash
nix build .#nixosConfigurations.<host>.config.system.build.toplevel
nix build .#nixosConfigurations.<host>.config.system.build.diskoScript
nix run nixpkgs#nixos-anywhere -- --vm-test --flake .#<host>   # full dry run in a VM
```

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
  --extra-files "$tmp" --flake .#<host> root@<target-ip>
```

`--extra-files` copies its contents onto the target's root `/` as-is, so the
key is staged under `persistent/var/lib/sops-nix/` (where the bind-mounted
`/var/lib/sops-nix` actually lives). Without it the new system has no sops key
and no user password.

`disko` wipes the target disk without asking; run the `--vm-test` rehearsal
from step 1 first if the layout is unproven.

### 4. First boot

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
