{config, ...}: let
  username = config.flake.meta.user.username;
in {
  flake.modules.homeManager."programs/github-cli" = {pkgs, ...}: {
    programs.gh.enable = true;
  };

  # Preservation companion for "programs/github-cli" (auto-resolved by the
  # prefix). HM generates config.yml as a store symlink; the durable state
  # is hosts.yml (auth credentials, created by `gh auth login`) plus any
  # runtime state in the same dir — whole-dir so it rides alongside the
  # HM symlink (chromium External Extensions pattern).
  flake.modules.nixos."preservation/programs/github-cli" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username} = {
      directories = [
        ".config/gh"
      ];
    };
  };
}
