{
  pkgs,
  inputs,
  lib,
  config,
  ...
}: let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
  cfg = config.night-sky.programs.spotify;
in {
  options.night-sky.programs.spotify = {
    enable = lib.mkEnableOption "spotify";
  };

  imports = [inputs.spicetify-nix.homeManagerModules.default];

  config = lib.mkIf cfg.enable {
    programs.spicetify = {
      enable = true;
      # theme = spicePkgs.themes.catppuccin;
      # colorScheme = "mocha";

      enabledExtensions = with spicePkgs.extensions; [
        # fullAppDisplay
        shuffle # shuffle+ (special characters are sanitized out of ext names)
        hidePodcasts
        adblock
      ];
    };
  };
}
