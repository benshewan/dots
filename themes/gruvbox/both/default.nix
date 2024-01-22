{
  outputs,
  pkgs,
  config,
  ...
}: {
  stylix.image = "${outputs.wallpapers}/gruvbox/gruvbox-dark-blue.png";
  stylix.polarity = "dark";
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
  stylix.cursor = {
    name = "Capitaine Cursors (Gruvbox)";
    package = pkgs.capitaine-cursors-themed;
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
