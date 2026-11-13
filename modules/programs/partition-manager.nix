{config, ...}: let
  username = config.flake.meta.user.username;
in {
  flake.modules.nixos."programs/partition-manager" = {pkgs, ...}: {
    programs.partition-manager.enable = true;
    environment.systemPackages = with pkgs; [
      # Needed for partition manager exfat support
      exfatprogs
    ];
  };

  # Preservation companion for "programs/partition-manager" (auto-resolved
  # by the prefix). Its only state is KConfig window furniture —
  # ~/.config/partitionmanagerrc (status bar toggle) and
  # ~/.local/state/partitionmanagerstaterc (geometry) — and KConfig saves
  # atomically (temp file + rename(2)), which fails with EBUSY on a
  # preservation file bind mount and swallows the write (dolphinrc lesson).
  # Near-zero-value state anyway, so both are left volatile. No durable
  # state to preserve; the companion intentionally stays empty except for
  # this comment.
  flake.modules.nixos."preservation/programs/partition-manager" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username} = {};
  };
}
