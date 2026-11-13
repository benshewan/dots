{config, ...}: let
  # Flake-level user metadata; config.flake does not exist inside NixOS
  # modules, which shadow `config` with the host config.
  username = config.flake.meta.user.username;
in {
  flake.modules.homeManager."programs/bottles" = {pkgs, ...}: {
    home.packages = [
      (pkgs.bottles.override {
        removeWarningPopup = true;
      })
    ];
  };

  # Preservation companion for "programs/bottles" (auto-resolved by the prefix).
  flake.modules.nixos."preservation/programs/bottles" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username} = {
      directories = [
        # Bottles, prefixes, runners and installer state. Bottles Next keeps
      # everything under XDG data; there is no .config side.
      ".local/share/bottles"
      ];
    };
  };
}
