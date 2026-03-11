_: {
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
        local.harper-obsidian-plugin
      ];
    };
  };
}
