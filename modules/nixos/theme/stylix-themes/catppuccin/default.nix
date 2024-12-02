{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.night-sky.theme;
in
  lib.mkIf (cfg
    == "catppuccin") {
    stylix.image = ./wallpapers/catppuccin-floral.png;
    stylix.polarity = "dark";
    stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    # stylix.cursor = {
    #   name = "catppuccin-mocha-light-cursors";
    #   package = pkgs.catppuccin-cursors.mochaLight;
    #   size = 32;
    # };
    stylix.cursor = {
      name = "phinger-cursors-light";
      package = pkgs.phinger-cursors;
      size = 32;
    };
    # Fonts
    stylix.fonts = {
      # serif = {
      #   package = pkgs.dejavu_fonts;
      #   name = "DejaVu Serif";
      # };
      serif = config.stylix.fonts.sansSerif;

      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
        # package = pkgs.nerdfonts.override {fonts = ["DejaVuSansMono"];};
        # name = "DejaVuSansMono";
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
