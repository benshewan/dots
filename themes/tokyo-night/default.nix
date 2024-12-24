{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.night-sky.theme;
  inherit (pkgs.stdenv) isLinux;
in
  lib.mkIf (cfg == "tokyo-night") {
    stylix =
      {
        image = ./wallpapers/thing.png;
        polarity = "dark";
        base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-storm.yaml";

        fonts = {
          # serif = {
          #   package = pkgs.dejavu_fonts;
          #   name = "DejaVu Serif";
          # };
          serif = config.stylix.fonts.sansSerif;

          sansSerif = {
            package = pkgs.dejavu_fonts;
            name = "DejaVu Sans";
            # package = pkgs.nerd-fonts.jetbrains-mono;
            # name = "DejaVuSansMono";
          };

          monospace = {
            package = pkgs.nerd-fonts.jetbrains-mono;
            name = "JetBrainsMono NF";
          };

          emoji = {
            package = pkgs.noto-fonts-emoji;
            name = "Noto Color Emoji";
          };
        };
      }
      // (
        if (isLinux == true)
        then {
          cursor = {
            name = "phinger-cursors-light";
            package = pkgs.phinger-cursors;
            size = 32;
          };
        }
        else {}
      );
  }
