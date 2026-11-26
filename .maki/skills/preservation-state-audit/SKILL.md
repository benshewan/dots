---
name: preservation-state-audit
description:
  Thoroughly test what state new software creates on this repo's NixOS hosts
  (caelum, navis), diff the live home directory against the preserved state to
  find every new file and folder it writes, classify each as preserved /
  Home-Manager-generated / deliberately volatile / missing-from-preservation,
  and set up or extend a `preservation/<feature>` companion module. Use when
  asked to "test what state X creates", "audit X's state", "add preservation
  for X", "set up a preservation module", "check if X's state is covered",
  before or after enabling a new program on a host, or when the user reports
  files appearing in the home root after using an app.
---

# Preservation state audit

This repo runs erase-your-darlings: the root is wiped every boot and only
paths registered with `preservation` (bind-mounted from `/persistent`) survive.
The home directory is granular: each app's state is declared by a companion
module inside the app's own file. An app whose state is not registered loses
everything on reboot; a directory registered that HM already generates is
useless clutter. The job of this skill is to get every app's state classified
correctly with evidence, not guesswork.

## 0. Ground rules for this repo

- Persistent path: `/persistent` (`modules.preservation.persistentPath`).
  User: `ben` (`config.flake.meta.user.username`).
- Essentials (XDG user dirs, `.ssh` via the ssh module, `.gnupg`, dconf,
  keyrings, `.local/state/{nix,home-manager}`) live in
  `modules/system/preservation-home.nix`. **Never** re-register them in an
  app companion (the duplicate-path assertion fails the eval).
- Everything app-specific lives in the app's own module file as
  `flake.modules.nixos."preservation/<feature>"` where `<feature>` is the
  name the host resolves (e.g. `programs/maki`, `services/kdeconnect`,
  `window-managers/mangowm` — the feature key, not the file name).
- HM-only apps CAN carry NixOS companions: `resolve()` in
  `modules/flake-parts/lib.nix` attaches companions for every feature name in
  the resolve list regardless of namespace.
- **Untracked files are invisible to the flake.** After creating or editing
  any module file: `git add <file>` (staging is enough) or the eval fails with
  `string '<key>' doesn't represent an absolute path`.
- Hosts: caelum is the rehearsal VM (`root@192.168.122.193` over SSH, works
  non-interactively). Test there first; navis follows later.
- A user path is owned by exactly one companion per host. If two features
  register the same path (docker's and podman's `.config/docker`), only
  one may be resolved at a time — swap them in the resolve list, never
  resolve both.

## 1. Set up the preservation companion

In the app's module file, capture the username at the **file level** — inside
a NixOS module `config` is the host config and `config.flake` does not exist
(this has bitten repeatedly; see `luks-btrfs.nix:44`):

```nix
{config, ...}: let
  # Flake-level user metadata; config.flake does not exist inside NixOS
  # modules, which shadow `config` with the host config.
  username = config.flake.meta.user.username;
in {
  flake.modules.homeManager."programs/example" = {pkgs, ...}: {
    # ...the feature itself...
  };

  # Preservation companion for "programs/example" (auto-resolved by the prefix).
  flake.modules.nixos."preservation/programs/example" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username} = {
      directories = [
        # why each entry is real runtime state, one comment per line
        {directory = ".config/example"; mode = "0700";}   # private state
        ".local/share/example"
      ];
      files = [
        # single-file state MUST go here, not directories: declaring a file
        # path under directories bind-mounts a DIRECTORY over it and the
        # app's config write fails with EISDIR (bit us with dolphinrc).
        ".config/examplerc"
      ];
    };
  };
}
```

Rules for choosing entries:

- `directories` for app state dirs (0700 when it holds credentials/keys).
- `files` for standalone config files the app writes back. **Caution:
  file bind mounts only work for apps that write in place.** Apps that
  save atomically (temp file + `rename(2)` onto the target) get `EBUSY`
  renaming onto a file mountpoint and often swallow the failure
  (`kwriteconfig6` exits 0 with nothing written; verify with
  `strace -e trace=rename,renameat <app>`). The `symlink` method loses
  atomic-rename updates at reboot too (the rename replaces the symlink
  with a real volatile file). When in doubt, leave the file volatile and
  note the decision in a comment.

  **KDE/KConfig is the flagship case**: settings live as loose `*rc` files
  in the root of `~/.config` (dolphinrc, kdeconnectrc, ...), saved by
  atomic rename *by design*. File mounts EBUSY on the rename and the
  symlink method loses the update, so KDE rc files stay volatile (the
  only mount-based fix is a wholesale `~/.config` anchor, rejected here
  for hygiene). An app's durable KDE state is `~/.local/share/<app>`,
  which IS a directory and preserves fine.
- Skip anything HM generates (`xdg.configFile`/`home.file` in the module or
  stylix targets): it is regenerated at every activation.
- Skip caches (`.cache/*`, SQLite `-wal`/`-shm` siblings are fine to skip,
  history DBs are not).
- Skip runtime pointers (pid/lock files, symlinks into other state, e.g.
  `~/.steampid`/`~/.steampath` → into `.steam`); note the decision in a
  comment so nobody "fixes" it later.
- Watch for apps writing to the home ROOT, not XDG dirs (`.vscode`,
  `.vscode-shared`, `~/<Ide>Projects`): sweep depth 1, not just `.config`.
- Recurring patterns (full rationale lives in preservation-home.nix
  comments):
  - Electron/Chromium: preserve the whole `~/.config/<Vendor Name>`
    profile dir (connections/cookies/LevelDB). Mime registrations edit
    `~/.config/mimeapps.list` by atomic rename → volatile; declare the
    associations via HM `xdg.mimeApps` instead.
  - Shared framework roots → preservation-home essentials, never an app
    companion: `.local/share/pki` (NSS DB of all Chromium/Electron apps;
    Firefox has its own), `.java` (java.util.prefs userRoot),
    `~/.config/pulse/cookie` (cross-app libpulse auth, written once — a
    safe file mount). The companion then carries only a pointer comment.
  - Java apps: `~/.java/.userPrefs/com/<vendor>` IS the settings store;
    `~/.skiko` and `<app>/locks` are caches/locks — skip.
  - JetBrains also writes `~/.java/.userPrefs/jetbrains`.
  - App-id dirs don't always match the app name: Helium (Chromium fork)
    uses `.config/net.imput.helium`, NOT `.config/helium`.
- HM gotcha: HM `services.pipewire` has NO `extraConfig` (NixOS-only).
  Resolution for audio-relay: keep the virtual-mic graph in its own
  `flake.modules.nixos."programs/audio-relay"` module in the same file —
  NixOS extraConfig attaches wherever the feature resolves, no HM
  workaround. Also HM `xdg.mimeApps.associations` is split into
  `added`/`removed` sub-attrs.

Before trusting a directory needs preserving, check whether HM already
generates it:

```sh
nix eval --json --apply 'f: let hm = f.config.home-manager.users.ben; in
  builtins.attrNames (builtins.filterAttrs (n: builtins.match ".*example.*" n != null)
    (hm.xdg.configFile // hm.home.file))' .#nixosConfigurations.caelum
```

(btop's config is fully HM-generated — its companion was removed for exactly
this reason.)

## 2. Enable, stage, evaluate

1. Add the feature to the host's `resolve` list in `machines/<host>/<host>.nix`.
2. Update the host's single "State-audit batches" comment block in place
   when rotating features — never stack a new copy of it.
3. `git add -A modules/`
4. `nix eval --json --apply 'f: let n = f.config; in
   { drv = n.system.build.toplevel.drvPath or "FAIL";
     dirs = map (d: d.directory or d)
       (n.preservation.preserveAt."/persistent".users.ben.directories); }'
   .#nixosConfigurations.caelum`

`nix eval` on a host gives a raw module result — everything must go through
`f.config.*`. The eval failing on the duplicate-path assertion means two
companions registered the same path.

## 3. Deploy

```sh
nixos-rebuild switch --flake .#caelum --target-host root@192.168.122.193
```

A live switch is enough for the audit; use a reboot only when you want to
prove state survives the wipe (worth doing once per app: write a marker file
into the app's state dir, reboot, confirm it is still there and that the
volatile copy is gone).

**Unloading a companion mid-rotation can fail the switch**: when the batch's
features are removed from the resolve list, the switch tries to stop the
removed `home-*` mount units and exits non-zero if one can't be unmounted
(bit us with sunshine). The new config still activates. Check for leftover
stale mounts afterwards: `mount | grep /home/ben` and `umount` any path
whose companion is gone.

**sops secrets vs preservation mounts (batch 5 trap)**: on this host sops
renders secrets during the INITRD NixOS activation ("NixOS Activation" /
"setting up secrets for users"), which runs BEFORE stage-2 preservation
mounts — a secret whose `path` sits under a mounted dir gets its symlink
created on the volatile side and then SHADOWED by the mount. Fix: a tmpfiles
`L+` rule (stage-2 tmpfiles runs after the mounts, and re-runs on every
switch) re-creating the symlink inside the mount, e.g.
`L+ /home/u/.local/share/filebot/data/.license - - - - /run/secrets/<name>`.
Related: sops-install-secrets creates the secret's PARENT dirs root-owned;
pre-create the chain with `d` tmpfiles rules (it leaves existing dirs alone)
if the app must write beside the secret. Verify the end state empirically —
an `ls` through the mount vs `/persistent` during debugging can lie if you
unmount/re-mount mid-investigation.

## 4. Diff live state against preserved state

Snapshot BEFORE running the app, run the app, snapshot again, diff. The
classification needs the mount list, so capture it in both snapshots:

```sh
# run as root on the host; snapshot in a file
snap() { find /home/ben -xdev -maxdepth 3 \
    \( -path '*/.cache*' -o -path '*/node_modules*' \) -prune -o \
    \( -type f -o -type d \) -print 2>/dev/null; }
snap > /tmp/before.txt
# ... use the app ...
snap > /tmp/after.txt
comm -13 <(sort /tmp/before.txt) <(sort /tmp/after.txt)   # new paths
```

Then classify every new path with the mount map:

```sh
for p in $(comm -13 <(sort /tmp/before.txt) <(sort /tmp/after.txt)); do
  d=$p; while [ "$d" != "/home/ben" ] && ! mountpoint -q "$d"; do
    d=$(dirname "$d"); done
  if mountpoint -q "$d"; then echo "PRESERVED  $p"; else echo "VOLATILE   $p"; fi
done
```

- **PRESERVED** — inside a bind mount; content lands on `/persistent`. Done.
- **VOLATILE** — every one of these needs a verdict:
  - HM-generated (symlink into `/nix/store`, or written by HM/stylix at each
    activation) → fine, no entry.
  - Regenerable cache/junk → fine, no entry.
  - Real runtime state → **add it to the companion** (step 1), redeploy, and
    re-verify it now reports PRESERVED.
- Also sweep depth 1 for home-root artifacts the app invented:
  `find /home/ben -maxdepth 1 -mindepth 1` + the same mountpoint walk.
- Confirm the persistent side actually received data:
  `du -sh /persistent/home/ben/<dir>` after the app ran (a mounted but empty
  dir after real use usually means the app writes elsewhere).

**Why "0 new paths" can be a PASS**: the snap `find -xdev` deliberately
never descends into preservation bind mounts, so an app whose state lands
entirely inside its mounts reports no new paths. Don't misread that as a
broken diff — verify via `du` on the persistent side instead.

**Global unpreserved sweep** — the per-app diff only catches state written
during the audit window by apps you relaunch. The wipe is the oracle for
the rest: the root is rolled back every boot, so EVERY file in the live
home that is not under a preservation mount was written since boot and
dies at the next reboot. One command lists it all:

```sh
# run as root on the host
find /home/ben -xdev -mindepth 1 \
  \( -path '*/.cache*' -prune \) -o \
  ! -type l -print
```

`-xdev` stops at every preservation mount (by construction), `-type l`
drops HM-generated store symlinks and runtime pointers, `.cache` is
junk by policy. Everything left is unpreserved state — classify each
hit with the rules in step 1, then either register it or note why it is
fine to lose. Run this after any audit batch to catch state written by
apps that were never re-run for their companion review.

## 5. Launching apps for the audit (GUI, over SSH)

The caelum GUI session can be driven from SSH when a user session exists
(`loginctl list-sessions`). caelum boots straight into the session via the
`display-managers/auto-login` module (greetd initial_session — see
modules/display-managers/auto-login.nix), so a session is usually already
up. On other hosts, temporarily enable that module in the host config,
rebuild, reboot — and remove it again afterwards (mark TEST-ONLY).

Launch through the user's systemd manager so the session env (Wayland, dbus)
applies:

```sh
# WRONG: runuser inherits root's PATH; the user manager PATH lacks the HM
# profile too (apps die with status 203/EXEC without absolute paths).
systemd-run --user -M ben@.host --unit=audit-<app> \
  "$(readlink -f /etc/profiles/per-user/ben/bin/<app>)"
sleep 8; systemctl --user -M ben@.host is-active audit-<app>
# stop with: systemctl --user -M ben@.host stop audit-<app>
```

Traps learned the hard way on caelum:

- `runuser -u ben` keeps root's cwd (`/root`) — the child fails with
  "cannot chdir to /root" before the app even starts. `cd /home/ben`
  first (or ssh straight into it: `ssh root@host 'cd /home/ben && bash -s'`).
- Root's `DBUS_*` env leaks through runuser and points apps at
  /run/user/0 (e.g. podman logging "dial unix /run/user/0/bus:
  permission denied"). Strip it:
  `env -u DBUS_SESSION_BUS_ADDRESS -u DBUS_SYSTEM_BUS_ADDRESS`.
- Commands that attach stdin (`docker compose exec -T`, anything reading
  a pty) silently consume the rest of an `ssh 'bash -s' <<'EOF'` script —
  the script just stops mid-run. Redirect their stdin (`< /dev/null`) or
  use a separate ssh call.

- The user-manager PATH does not contain the HM profile — always pass the
  resolved absolute store path.
- `runuser -u ben` keeps root's PATH and `$HOME`; `fs.protected_regular`
  blocks root writing `/tmp/app.log` in sticky dirs — log inside the home.
- The binary name may not be what you think: firefox is
  `firefox-devedition`, vscode is `code`, zed is `zeditor` (and detaches
  unless run with `--foreground` — a running-but-detached app looks "failed"
  if you only check the unit).
- Never `pkill -f <name>` from inside a test script: the pattern matches the
  script's own cmdline and kills it. Kill the captured PID or the unit.
- TUI apps can be driven without a GUI via a pty:
  `runuser -u ben -- script -qec "yazi" /dev/null`.
- MESA/radv errors on the VM's QXL GPU are cosmetic (software rendering).

## 6. Non-GUI checks worth running

- HM regeneration coverage: reboot (or restart
  `systemctl --user -M ben@.host restart home-manager-ben.service`) and
  confirm nothing the user authored disappeared.
- Duplicate registration: `nix eval` of the users.ben directories list —
  each path exactly once across companions + essentials.
- Mount health after deploy:
  `mount | grep "home/ben" | wc -l` and `systemctl --failed --no-legend`.
- If a companion switched a path between files/directories on a live system,
  the persistent side may hold the stale type (a dir where a file belongs).
  Fix: stop both `home-ben-…` and `persistent-home-ben-…` mount units, remove
  the stale path, `systemd-tmpfiles --create`, restart the mount unit.
