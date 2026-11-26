{config, ...}: let
  # Flake-level user metadata; config.flake does not exist inside the NixOS
  # modules below, which shadow `config` with the host config.
  username = config.flake.meta.user.username;
in {
  flake.modules.homeManager."programs/ghidra" = {pkgs, ...}: {
    # Reverse-engineering framework (Apache-2.0). Heavy Java app; the
    # derivation bundles its own JDK, no extra Java setup needed.
    home.packages = [pkgs.ghidra];
  };

  # Preservation companion for "programs/ghidra" (auto-resolved by the prefix).
  # Audited on caelum 2026-11-25 (Ghidra 12.2): first GUI launch creates
  # ~/.config/ghidra/ghidra_12.2_NIX/ (settings dir is versioned AND
  # release-tagged, so its name changes on every upgrade) with `preferences`,
  # the tool chest in `tools/_*.tcd`, `java_home.save`, plus `lastrun` in the
  # parent — all real durable state that lands on the persistent side.
  flake.modules.nixos."preservation/programs/ghidra" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username}.directories = [
      # Whole user-settings tree (XDG layout since Ghidra 11.1, GP-1164):
      # preferences, FrontEndTool.xml, the tool chest in tools/, themes/,
      # GUI-installed extensions/, compiled script bundles in osgi/, and
      # lastrun. The regenerable parts inside (application.log/script.log,
      # symbols/ — the downloaded PDB store) ride along on purpose: the
      # versioned dir name (ghidra_<version>_<release>) already changes every
      # upgrade, so a per-subdir enumeration would break on each one while
      # one mount covers all of them (same wholesale-mount rationale as
      # /var/lib/systemd in the preservation base module).
      #
      # Deliberately NOT preserved: Ghidra 12.2's cache lives in
      # ~/.cache/ghidra (observed at runtime; the pre-11.1 /var/tmp/<user>-ghidra
      # location is outdated) and its temp dir in /tmp/<user>-ghidra — both
      # outside any mount on the rolled-back root, which is exactly right for
      # a cache. java.util.prefs (the shared .java/.userPrefs root) is an
      # essentials entry in system/preservation-home.nix; the audit observed
      # no writes there — Ghidra keeps its preferences inside the settings
      # dir above.
      ".config/ghidra"
      # Default user-script directory (added to the Script Manager by
      # default). Created only when a script is first saved there, i.e. it
      # holds hand-authored content, not regenerable state — without this
      # entry a reboot would silently eat every script the user wrote.
      "ghidra_scripts"
    ];
  };
}
