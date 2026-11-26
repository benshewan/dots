# AGENTS.md

Ben's NixOS / Home Manager configuration ("dots"). Three hosts are defined
here: **navis** (Framework 13 AMD laptop, primary), **caelum** (QEMU/KVM guest
on navis — rehearsal host for risky changes), **apus** (headless server VM).
Everything is declarative: erase-your-darlings storage (preservation), sops
secrets, disko disk layouts, Secure Boot + measured boot.

## Critical rules

- **`flake.nix` is generated.** Never edit it by hand. Inputs are declared as
  `flake-file.inputs.*` inside flake-parts modules (e.g.
  `modules/system/kernel.nix`, `modules/system/secure-boot.nix`); regenerate
  with `nix run .#write-flake`. New files must be `git add`-ed (intent-to-add
  is enough: `git add -N`) or the flake eval fails with
  `string '<key>' doesn't represent an absolute path`.
- **Never run `nixos-rebuild` or `home-manager switch` yourself.** Build to
  validate instead (see "Verification"), and let the user do the switching
  (`./bootstrap.sh <host>` is their tool).
- **Nothing is installed imperatively.** If a tool is missing, use
  `nix shell nixpkgs#<tool> -c <tool> ...` / `nix run nixpkgs#<tool>` for
  ad-hoc use; a tool needed repeatedly belongs in this repo.
- **Secrets never enter the repo in plaintext.** All secrets are sops files
  under `secrets/`; see the Secrets section before touching anything there.
- **Comments are short and to the point.** One or two lines explaining *why*
  where a decision is non-obvious (why a path is preserved, why `resume=` is
  not set); skip anything the code already says. Never reference how things
  looked in the past ("used to", "previously", "was removed", "the old X") —
  comments describe the code as it is now.

## How the flake works

`flake.nix` is a thin [flake-parts](https://flake.parts) wrapper whose only
imports are two [import-tree](https://github.com/denful/import-tree) calls:

- `(import-tree ./modules)` — imports **every** `.nix` file under `modules/`
  as a flake-parts module, recursively.
- `(import-tree (matchNot "/[^/]+/hardware-configuration\.nix$") ./machines)` —
  same for `machines/`, except `hardware-configuration.nix` files, which stay
  raw `nixos-generate-config` output so `nixos-anywhere --generate-hardware-config`
  can overwrite them verbatim.

So there are **no central import lists**. Dropping a `.nix` file into the tree
is enough; what it registers depends on the `flake.modules.<namespace>."<key>"`
attributes it sets:

```nix
flake.modules.nixos."services/ssh"      # NixOS module, resolvable as "services/ssh"
flake.modules.homeManager."programs/yazi"  # Home Manager module
flake.modules.darwin.system             # nix-darwin module (rarely used)
```

The key is the module's *feature name*; the file's location is convention only
(keep them aligned: `modules/services/ssh.nix` registers `"services/ssh"`).
**Multiple files may contribute to the same key** — the module system merges
them. E.g. the `"system"` NixOS module is assembled from `core.nix`,
`commands.nix`, `nix.nix`, `kernel.nix`, `github-token.nix`, and
`modules/flake-parts/sops-nix.nix`; `programs/firefox` (HM) is spread over five
files in `modules/programs/browsers/firefox/`.

Flake-parts wiring itself lives in `modules/flake-parts/`:

| File | Purpose |
|---|---|
| `hosts.nix` | Builds `nixosConfigurations`/`darwinConfigurations` from `hosts/*` modules (see Hosts) |
| `lib.nix` | `config.flake.lib.resolve` (+ `resolveNix/Hm/Darwin`, `mkOpt`) |
| `meta.nix` | `flake.meta` options: user identity (`ben`), host list (timezone, dns, ssh keys), `flake-path` |
| `nixpkgs.nix` | Auto-discovers `packages/`, exposes `flake.overlays.default` (`pkgs.local.*`) |
| `preservation.nix` | The `preservation` NixOS module + OS-level preserved state |
| `sops-nix.nix` | Wires sops-nix into the `system` module |
| `disko.nix` | Wires disko (imported by disk layouts) |
| `flake-file.nix` / `flake-parts.nix` | Regeneration source for `flake.nix` |

## Repository layout

```
machines/<host>/         Host definitions (auto-attached per host)
  <host>.nix             Registers flake.modules.nixos."hosts/<host>" + meta.hosts
  hardware-configuration.nix   Raw nixos-generate-config output (excluded from import-tree)
  *.nix (anything else)  Host-scoped NixOS modules, e.g. "machines/navis/hardware"
modules/
  flake-parts/           Flake plumbing (see above)
  presets/               Named bundles of resolve() imports (desktop, laptop, server, mangowm, hyprland)
  system/                Base NixOS config, all merged into the "system" module
  disk-layouts/         disko layouts (luks-btrfs, btrfs, ext4)
  programs/ services/   Feature modules (mostly one feature each)
  desktop/ display-managers/ window-managers/ themes/ security/ shell/ virtualization/
  users.nix              "users" NixOS + HM modules (declarative password via sops)
overlays/                Auto-imported as nixpkgs overlays by modules/system/nix.nix
packages/<name>/package.nix   Custom packages, auto-discovered; usable as pkgs.local.<name>
patches/                Patch files referenced by overlays
secrets/                sops-encrypted files (common.yaml + hosts/<host>.yaml)
.maki/skills/preservation-state-audit/   In-repo agent skill (see Preservation)
bootstrap.sh            Rebuild a host (also provisions/validates its sops key)
install.sh              Historical navis-specific nixos-anywhere invocation (README is canonical)
```

## How a module is constructed

A feature module is a *flake-parts* file that registers one or more
namespaced modules, keyed by feature name. Hosts opt in by listing feature
names in `config.flake.lib.resolve [...]`. Canonical shape (from
`modules/programs/file-managers/yazi.nix`, abridged):

```nix
{config, ...}: let
  # Flake-level user metadata; config.flake does not exist inside the NixOS
  # module below, which shadows `config` with the host config.
  username = config.flake.meta.user.username;
in {
  flake.modules.homeManager."programs/yazi" = {pkgs, lib, ...}: {
    # ...the feature itself...
  };

  # Preservation companion for "programs/yazi" (auto-resolved by the prefix).
  flake.modules.nixos."preservation/programs/yazi" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username}.directories = [
      ".local/state/yazi"
    ];
  };
}
```

Key facts about `resolve()` (defined in `modules/flake-parts/lib.nix`):

- **Strings name registered features** ("presets/desktop", "programs/maki");
  paths/non-strings pass through as plain imports.
- NixOS-named strings attach on NixOS hosts, darwin-named ones on darwin;
  homeManager-named strings are attached to
  `home-manager.users.<default user>.imports` for the user from
  `flake.meta.user.username`.
- For every string in the list, a companion named `preservation/<string>` is
  searched in **all** namespaces and auto-imported where it exists. That is how
  app state follows its feature everywhere. A NixOS-side companion also pulls
  in the base `"preservation"` module automatically, so features stay
  preservation-agnostic.
- A string that exists in no namespace fails evaluation with a readable error
  listing every available module name — keep feature keys and resolve lists in
  sync.
- Wrapping (keyed imports) lets the same feature be resolved by several hosts
  without module-system dedup problems.

Conventions inside module bodies:

- Options custom to a feature live under `modules.<something>` (e.g.
  `modules.preservation.*`, `modules.diskLayouts.*`,
  `modules.displayManager.autoLogin`). `config.flake.lib.mkOpt` is a
  mkOption shorthand.
- Capture `username` (and anything else from `flake.meta`) **at the file
  level**, before the NixOS module: inside it, `config` is the host config and
  `config.flake` does not exist. This has bitten repeatedly (see
  `luks-btrfs.nix:44`).
- When an upstream input is needed, add `flake-file.inputs.<name>.url = ...`
  in the same feature file (with `inputs.<name>.nixpkgs.follows = "nixpkgs"`
  where appropriate) and run `nix run .#write-flake`.
- A feature may span namespaces: one file can register both a NixOS and an HM
  part of the same feature name (e.g. `programs/maki`,
  `virtualization/podman`), or only the side that matters.

### Presets

`modules/presets/*` are just resolve-list bundles: `presets/desktop` pulls in
users, desktop, fonts, stylix, ssh, git, firefox, fish, etc.;
`presets/laptop` = desktop + upower/bolt/fwupd/power-profiles-daemon;
`presets/server` = users + ssh + system. Hosts compose a preset with
individual feature names and a theme (`theme/gruvbox-dark`, `theme/everforest`
— stylix settings + wallpapers).

## Hosts

A host lives in `machines/<host>/<host>.nix` and registers two things:

- `flake.meta.hosts = [{ name, timezone, dnsServers, sshPublicKey, ... }]`
  (options declared in `modules/flake-parts/meta.nix`; consumed by
  `hosts.nix` for `time.timeZone` defaults).
- `flake.modules.nixos."hosts/<host>" = { ... }` — the actual host module:
  `imports = config.flake.lib.resolve [ ... ]` plus host-specific settings
  (disk layout parameters, monitors via the `monitors` HM option, firewall,
  SSH rescue keys that work even if sops decryption fails).

`modules/flake-parts/hosts.nix` then builds each
`nixosConfigurations.<host>` with: the host module, the home-manager NixOS
module (`useGlobalPkgs`, `useUserPackages`), `networking.hostName`, **every
module registered as `machines/<host>/*`** (auto-attached, e.g.
`machines/navis/hardware.nix`, `machines/caelum/provisioning.nix`), and
`machines/<host>/hardware-configuration.nix` by path if it exists.

Adding a machine = create `machines/<host>/<host>.nix`, pick a disk layout,
provision its sops key, install with nixos-anywhere — step-by-step in
README.md, which is the canonical procedure.

Host-specific quirks worth knowing:

- **caelum** rotates "state-audit batches" of feature modules through a
  commented block in `caelum.nix` — update it in place, never stack copies.
  It has passwordless sudo and auto-login (it's a test VM).
- **navis** runs the cachyos kernel (`boot.kernelPackages =
  pkgs.cachyosKernels...`, overlay from `modules/system/kernel.nix`).
- Hosts can override module settings with `lib.mkForce` where a feature
  module used `mkDefault` (e.g. shell selection in `users.nix` uses
  `mkOverride 500` because several modules set defaults).

## Secrets (sops-nix)

Managed with [sops-nix](https://github.com/Mic92/sops-nix) and **post-quantum
age keys** (hybrid ML-KEM-768 + X25519, `age-keygen -pq`).

- `secrets/common.yaml` — shared secrets, encrypted to both admin keys and
  every host key; it is the `defaultSopsFile` (wired in
  `modules/flake-parts/sops-nix.nix`, which also sets
  `sops.age.keyFile = "/var/lib/sops-nix/key.txt"` and installs sops/age/
  age-plugin-fido2-hmac system-wide).
- `secrets/hosts/<host>.yaml` — host-only secrets (LUKS passphrases, recovery
  keys, `atticd-env`), referenced per-secret with
  `sops.secrets."<name>".sopsFile = ../../secrets/hosts/<host>.yaml`.
- Recipients are declared in `.sops.yaml` creation rules:
  - `&admin_benshewan` — software PQ age key, recovery key, lives in
    `~/.config/sops/age/keys.txt` (gitignored).
  - `&admin_yubi5A` — hardware-backed `age-plugin-fido2-hmac` identity on a
    YubiKey; useless without the token + PIN. The software key is the backup —
    it must stay in `keys.txt` or secrets could become undecryptable.
  - `&navis` / `&caelum` / `&apus` — per-host PQ keys. Admin copies live at
    `~/.config/sops/age/hosts/<host>.key`; the host decrypts with its key at
    `/var/lib/sops-nix/key.txt` (preserved in the initrd via the
    `preservation/system` companion).

Editing/rotating:

```bash
# Edit (needs an admin key; token only if decrypting with the YubiKey):
nix shell nixpkgs#sops nixpkgs#age nixpkgs#age-plugin-fido2-hmac -c sops secrets/common.yaml

# After changing recipients in .sops.yaml:
nix shell nixpkgs#sops nixpkgs#age -c sops updatekeys secrets/common.yaml
```

Consumer patterns to copy: `users.nix` forces the login password declaratively
(`users.mutableUsers = false`, `hashedPasswordFile` from the `user-password`
secret with `neededForUsers = true` so it decrypts before user creation);
`modules/system/github-token.nix` points `nix.settings.netrc-file` at a sops
secret to lift GitHub rate limits; caelum's provisioning reads
`luks-passphrase`/`luks-recovery-key` at runtime. `bootstrap.sh` generates a
missing host key, installs it, and **refuses** to generate a new one if the
host's recipient is already in `.sops.yaml` (it would be a different key and
couldn't decrypt existing secrets).

Over SSH there is no seat: the fido2 uaccess rule doesn't apply, so run sops
with sudo there, or edit secrets at the machine.

Watch `.envrc` (direnv): it exports `SOPS_AGE_KEY_FILE` to an
`~/Documents/sops/age/keys_old_plain.txt` path — if that file is absent on
your checkout, sops decryption will fail with a confusing "no keys found";
override `SOPS_AGE_KEY_FILE` explicitly (e.g. to the admin or host key).

## Preservation (erase-your-darlings)

Hosts with `disk-layouts/luks-btrfs` or `disk-layouts/btrfs` wipe `/` at every
boot (btrfs rollback to a `root-blank` snapshot). Durable state survives only
if bind-mounted from `/persistent` via
[nix-community/preservation](https://github.com/nix-community/preservation).

- The base module (`modules/flake-parts/preservation.nix`, feature name
  `"preservation"`) enables OS-level state: `/var/log`, `/var/lib/nixos`,
  `/var/lib/systemd` (wholesale — see comment there), `/var/lib/private`,
  `/var/lib/lastlog`, `/etc/machine-id`, `/etc/adjtime`. It asserts that the
  persistent filesystem is declared with `neededForBoot = true`, and **fails
  the eval if any path is registered for preservation twice** — every path has
  exactly one owner.
- User state is granular (`modules.preservation.home = true`, feature
  `system/preservation-home`): only cross-app essentials (XDG dirs, `.gnupg`,
  `.local/state/nix`, `.local/state/home-manager`, keyrings, dconf, NSS DB
  `.local/share/pki`, `.java`, pulse cookie). **Never re-register those in an
  app companion.**
- App state is declared in the app's own file as a companion module
  `flake.modules.nixos."preservation/<feature-name>"`, auto-imported whenever
  the feature is resolved. Companions use
  `preservation.preserveAt.${config.modules.preservation.persistentPath}`
  (`.users.${username}.directories/files` for home state, top-level
  `directories/files` for system state).
- OS-level companions exist too: `preservation/system` (the sops key dir),
  `preservation/system/audit` (`/var/log/audit`),
  `preservation/system/secure-boot` (`/var/lib/sbctl`),
  `preservation/desktop` (bluetooth etc.).

Hard-won rules (full detail in `.maki/skills/preservation-state-audit/SKILL.md`
— read it before writing companions):

- `files` vs `directories` matters: a file path declared under `directories`
  bind-mounts a *directory* over it and the app's write fails with EISDIR.
- Apps that save atomically (temp + `rename(2)`) get EBUSY on file mounts —
  **KDE `*rc` files stay volatile by design**; preserve
  `~/.local/share/<app>` instead. The `symlink` method loses atomic-rename
  updates too.
- Skip HM-generated paths (`xdg.configFile`/`home.file`, stylix targets),
  caches, and runtime pointers (pid/lock files, symlinks into other state).
- A path owned by two features (docker vs podman `.config/docker`) means only
  one of the two features may be resolved per host — swap them in the resolve
  list, never resolve both.
- New apps should be audited on **caelum** first (the skill drives this over
  SSH: `root@192.168.122.193`); the audit finds every file the app writes and
  classifies it preserved / HM-generated / volatile / missing.

## Disk layouts

`modules/disk-layouts/` — each layout is a disko module keyed
`"disk-layouts/<name>"`, exposing options under `modules.diskLayouts.<attr>`.
A host opts in via resolve + parameters:

```nix
imports = flake.lib.resolve [ "preservation" "disk-layouts/luks-btrfs" ];
modules.diskLayouts.luksBtrfs = {
  device = "/dev/nvme0n1";     # whole disk is claimed and wiped
  swapSize = 64 * 1024;        # MiB; >= RAM to hibernate
};
```

- **luks-btrfs** (navis, caelum): GPT + 1G ESP + LUKS2 + btrfs; subvolumes
  `root` (wiped every boot by the initrd rollback service), `nix`,
  `persistent`, `swap` (own subvolume so persistent snapshots never drag the
  NOCOW swapfile along; `root-blank` is a READONLY snapshot). Assertions:
  preservation must be enabled, `persistentPath` must be `/persistent`,
  `measuredBoot` requires lanzaboote. `measuredBoot` (default: on when
  lanzaboote is enabled) binds the LUKS keyslot to systemd-pcrlock over PCRs
  0/4/7; the policy JSON must live on `/persistent` or the NV index changes
  on every rebuild and the TPM unlock silently degrades to a passphrase
  prompt (long comment in the file — don't "simplify" it away). Install-time
  passphrase comes from a file (`luksPassphraseFile`, uploaded via
  nixos-anywhere `--disk-encryption-keys`); `tpmPreSeal` seals an unbound TPM
  slot so the first boot is unattended. Hibernation deliberately does NOT set
  `boot.resumeDevice` (see comment: `resume=` breaks offset detection; the
  HibernateLocation EFI variable is used instead).
- **btrfs** (apus): same erase-your-darlings shape without LUKS/TPM/Secure
  Boot, for trusted-host VMs.
- **ext4** (navis's fallback): plain ESP + ext4 + optional `/swapfile`; no
  preservation needed.

Note: README.md also documents a `luks-zfs` layout that is **not present** in
`modules/disk-layouts/` — only the three above exist.

Keyslot provisioning beyond the layout runs on the installed host — see
`machines/caelum/provisioning.nix` (`caelum-provision` service: sops recovery
key + optional FIDO2 token enrollment via marker files in `/persistent`).

## Secure Boot

`"system/secure-boot"` (`modules/system/secure-boot.nix`) enables lanzaboote
with **fully unattended provisioning**: first boot generates the key set in
`/var/lib/sbctl` and reboots, the firmware enrolls PK/KEK/db (including
Microsoft keys — VM option ROMs and fwupd need them), later boots accept only
signed UKIs. `configurationLimit = 4` is a hard ceiling (1G ESP + pcrlock PCR 4
variant math) — don't raise it casually. The key set survives the root wipe via
the `preservation/system/secure-boot` companion.

## Packages, overlays, patches

- `packages/<name>/package.nix` is auto-discovered (scope built in
  `modules/flake-parts/nixpkgs.nix`) and available **inside NixOS config as
  `pkgs.local.<name>`** via `flake.overlays.default` (wired into
  `nixpkgs.overlays` by `modules/system/nix.nix`). Feature modules reference
  custom packages with `mkPackageOption pkgs.local "<name>" {}`.
- Every `.nix` file in `overlays/` is auto-imported as a nixpkgs overlay
  (also `modules/system/nix.nix`). Example: `mango-edid-refresh.nix` builds
  the mango compositor against `patches/wlroots-drm-refresh-edid-on-scan.patch`.
- `nixpkgs-stable` is available via `overlays/nix-stable.nix` (stable python,
  etc.).

## Verification and commands

```bash
# Evaluate/build a host without switching:
nix build .#nixosConfigurations.<host>.config.system.build.toplevel
nix build .#nixosConfigurations.<host>.config.system.build.diskoScript   # layout check

# Regenerate flake.nix after adding inputs or files:
git add -N <new-file> && nix run .#write-flake

# Ad-hoc tools (nothing is installed imperatively):
nix shell nixpkgs#jq -c jq -n '{a:1}'
nix search nixpkgs <term>

# User's rebuild entrypoint (don't run it yourself):
./bootstrap.sh <host> [switch|boot|test]
```

README.md documents the full new-machine install (nixos-anywhere + disko,
sops key staging, first-boot sequence) — treat it as canonical and keep it
updated when the install flow changes.

## Gotchas checklist

- `git add` (or `git add -N`) every new file before evaluating the flake.
- `config.flake` doesn't exist inside NixOS/HM modules — capture `username`
  and meta at the file level.
- One preserved path, one owner; the duplicate assertion fails the whole eval.
- Don't edit `flake.nix`; don't reformat or reorder its inputs.
- After changing `.sops.yaml` recipients, run `sops updatekeys` on every
  affected secrets file.
- Feature keys in resolve lists must exist in some namespace or eval throws;
  keep the key and the file location aligned.
- `hardware-configuration.nix` is generated — never hand-maintain it.
- Caelum's commented "audit rotation" block in `machines/caelum/caelum.nix`
  is a queue: rotate modules through it in place.
- Measured-boot hosts: changing `pcrlockDirectory`/preservation wiring (or
  anything that moves where lzbt's components live) has a one-time migration
  trap — the first switch writes the new UKI's component to the still-volatile
  path, the next boot prompts for the LUKS passphrase, and the policy update
  deadlocks until a fresh policy is minted and the token re-enrolled. Full
  story + recovery recipe in the comment block of
  `modules/disk-layouts/luks-btrfs.nix` ("MIGRATION TRAP").
- Comment *why*, not just *what* — and briefly: failure modes that took real
  debugging (EBUSY renames, pcrlock NV-index reuse, iTCO watchdog resets) earn
  a line or two, never paragraphs, and no "used to"/"previously" history.
  Comment the code as it is now.
