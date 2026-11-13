{config, ...}: let
  # Flake-level user metadata; config.flake does not exist inside NixOS
  # modules, which shadow `config` with the host config.
  username = config.flake.meta.user.username;
in {
  flake.modules.homeManager."programs/obsidian" = {
    pkgs,
    lib,
    ...
  }: {
    programs.obsidian = {
      enable = true;
      vaults."default" = {
        target = "Documents/Obsidian Vault";
      };
      defaultSettings.communityPlugins = with pkgs; [
        # local.harper-obsidian-plugin
      ];
    };
  };

  # Preservation companion for "programs/obsidian" (auto-resolved by the prefix).
  flake.modules.nixos."preservation/programs/obsidian" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username} = {
      directories = [
        # Vault registry and UI state. The vaults themselves live under
        # Documents (preserved via the essentials module).
      ".config/obsidian"
      ];
    };
  };
}
