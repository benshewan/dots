{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.night-sky.theme;
in
  lib.mkIf (cfg
    == "gruvbox") {
    stylix.image = ./wallpapers/gruvbox-dark-blue.png;
    stylix.polarity = "dark";
    stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";

    # Fonts
    # stylix.fonts = {
    #   serif = config.stylix.fonts.sansSerif;

    #   sansSerif = {
    #     package = pkgs.dejavu_fonts;
    #     name = "DejaVu Sans";
    #     # package = pkgs.nerd-fonts.dejavu-sans-mono;
    #     # name = "DejaVuSansMono";
    #   };

    #   monospace = {
    #     package = pkgs.nerd-fonts.jetbrains-mono;
    #     name = "JetBrainsMono";
    #   };

    #   emoji = {
    #     package = pkgs.noto-fonts-emoji;
    #     name = "Noto Color Emoji";
    #   };
    # };
  }
