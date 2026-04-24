{inputs, ...}: {
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
}
