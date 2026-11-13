{inputs, config, ...}: let
  # Flake-level user metadata; config.flake does not exist inside NixOS
  # modules, which shadow `config` with the host config.
  username = config.flake.meta.user.username;
in {
  flake-file.inputs = {
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager."programs/spotify" = {
    pkgs,
    lib,
    ...
  }: let
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  in {
    imports = [inputs.spicetify-nix.homeManagerModules.default];

    config = {
      programs.spicetify = {
        enable = true;
        # theme = spicePkgs.themes.catppuccin;
        # colorScheme = "mocha";

        enabledExtensions = with spicePkgs.extensions; [
          # fullAppDisplay
          shuffle # shuffle+ (special characters are sanitized out of ext names)
          hidePodcasts
          adblock
          sideHide
        ];
      };
    };
  };

  # Preservation companion for "programs/spotify" (auto-resolved by the prefix).
  flake.modules.nixos."preservation/programs/spotify" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username} = {
      directories = [
        # Login credentials and client preferences. Spicetify's own config is
        # declaratively managed by the module above.
      ".config/spotify"
      ];
    };
  };
}
