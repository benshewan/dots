{config, ...}: let
  # Flake-level user metadata; config.flake does not exist inside NixOS
  # modules, which shadow `config` with the host config.
  username = config.flake.meta.user.username;
in {
  flake.modules.homeManager."programs/direnv" = {
    pkgs,
    config,
    ...
  }: {
    programs.direnv = {
      enable = true;
      silent = true;
      nix-direnv.enable = true;
      enableFishIntegration = true;
    };
  };

  # Preservation companion for "programs/direnv" (auto-resolved by the prefix).
  flake.modules.nixos."preservation/programs/direnv" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username}.directories = [
      # The `direnv allow` cache; without it every project re-prompts.
      ".local/share/direnv"
    ];
  };
}
