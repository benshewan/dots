{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.night-sky.theme;
in
  lib.mkIf (cfg
    == "tokyo-night") {
    stylix.image = ./wallpapers/gruvbox-dark-blue.png;
    stylix.polarity = "dark";
    stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-moon.yaml";
    stylix.cursor = {
      name = "phinger-cursors-light";
      package = pkgs.phinger-cursors;
      size = 32;
    };
    # Fonts
    stylix.fonts = {
      serif = config.stylix.fonts.sansSerif;

      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };

      monospace = {
        package = pkgs.nerdfonts.override {fonts = ["JetBrainsMono"];};
        name = "JetBrainsMono";
      };

      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    };
  }
