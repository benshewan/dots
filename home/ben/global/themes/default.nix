{
  pkgs,
  inputs,
  config,
  ...
}: let
  inherit (inputs.nix-colors.lib.contrib {inherit pkgs;}) gtkThemeFromScheme;
in rec {
  imports = [inputs.nix-colors.homeManagerModules.default];
  colorScheme = inputs.nix-colors.colorSchemes.catppuccin-mocha;
  gtk = {
    enable = true;
    # font = {
    #   name = config.fontProfiles.regular.family;
    #   size = 12;
    # };
    cursorTheme = {
      name = "Catppuccin-Mocha-Dark-Cursors";
      package = pkgs.catppuccin-cursors.mochaDark;
      size = 32;
    };
    theme = {
      name = "${colorScheme.slug}";
      package = gtkThemeFromScheme {scheme = colorScheme;};
    };
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
  };
  services.xsettingsd = {
    enable = true;
    settings = {
      "Net/ThemeName" = "${gtk.theme.name}";
      "Net/IconThemeName" = "${gtk.iconTheme.name}";
    };
  };
  home.file.".config/gtk-4.0/gtk.css".source = "${gtkThemeFromScheme {scheme = colorScheme;}}/share/themes/${colorScheme.slug}/gtk-4.0/gtk.css";
  home.file.".config/gtk-4.0/gtk-dark.css".source = "${gtkThemeFromScheme {scheme = colorScheme;}}/share/themes/${colorScheme.slug}/gtk-4.0/gtk-dark.css";
  home.file.".config/gtk-4.0/assets" = {
    recursive = true;
    source = "${gtkThemeFromScheme {scheme = colorScheme;}}/share/themes/${colorScheme.slug}/gtk-4.0/assets";
  };

  home.packages = with pkgs; [adwaita-qt];

  qt = {
    enable = true;
    platformTheme = "gtk";
    style = {
      # name = "gtk2";
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };
}
