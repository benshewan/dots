{
  outputs,
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.night-sky.themes;
in
  lib.mkIf cfg
  == "catppuccin" {
    stylix.image = "${outputs.wallpapers}/catppuccin/catppuccin-floral.png";
    stylix.polarity = "dark";
    stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    stylix.cursor = {
      name = "Catppuccin-Mocha-Dark-Cursors";
      package = pkgs.catppuccin-cursors.mochaDark;
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
