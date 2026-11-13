{config, ...}: let
  username = config.flake.meta.user.username;
in {
  flake.modules.homeManager."programs/prism-launcher" = {
    pkgs,
    lib,
    ...
  }: {
    programs.java = {
      enable = true;
      package = pkgs.jdk;
    };
    home.packages = with pkgs; [
      (prismlauncher.override {jdks = [openjdk8 zulu17 zulu21 zulu25];})
    ];
  };

  # Preservation companion for "programs/prism-launcher" (auto-resolved by
  # the prefix). One dir holds everything: prismlauncher.cfg (settings),
  # instances/, meta/ and the icon/theme/translation caches.
  flake.modules.nixos."preservation/programs/prism-launcher" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username} = {
      directories = [
        ".local/share/PrismLauncher"
      ];
    };
  };
}
