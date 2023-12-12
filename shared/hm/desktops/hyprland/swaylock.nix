{
  pkgs,
  config,
  ...
}: let
  color = config.colorScheme.colors;
in {
  # stylix.targets.swaylock.enable = true;
  # stylix.targets.swaylock.useImage = true;
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock;
    settings = {
      # Only for the Effects fork, but effects seems prone to crashing
      # screenshots = true;
      # clock = true;
      # indicator = true;

      # Grace
      grace = 2;
      grace-no-mouse = true;

      # Effects
      # fade-in = 0.2;
      # effect-blur = "5x3";
      # effect-scale = 1;
    };
  };
}
