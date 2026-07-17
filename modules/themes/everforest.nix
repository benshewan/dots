_: {
  flake.modules.nixos."theme/everforest" = {
    pkgs,
    config,
    ...
  }: {
    stylix = {
      image = ./wallpapers/georges_riom_collage.png;
      polarity = "dark";
      base16Scheme = "${pkgs.base16-schemes}/share/themes/everforest.yaml";

      fonts = {
        serif = config.stylix.fonts.sansSerif;

        sansSerif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Sans";
        };

        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono NF";
        };

        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
      };
      cursor = {
        name = "everforest-cursors";
        package = pkgs.everforest-cursors;
        size = 32;
      };
    };
  };
}
