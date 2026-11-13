{config, ...}: let
  username = config.flake.meta.user.username;
in {
  flake.modules.homeManager."programs/helix" = {pkgs, ...}: {
    programs.helix = {
      enable = true;
    };
  };

  # Preservation companion for "programs/helix" (auto-resolved by the
  # prefix). Intentionally empty: config.toml + themes are HM/stylix
  # symlinks, and a first run (file opened in a pty) writes ONLY
  # ~/.cache/helix (runtime log) — helix keeps no durable state outside
  # its config. Do not "fix" this without evidence.
  flake.modules.nixos."preservation/programs/helix" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username} = {};
  };
}
