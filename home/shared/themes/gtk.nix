{
  pkgs,
  config,
  inputs,
  lib,
  ...
}: let
  inherit (inputs.nix-colors.lib.contrib {inherit pkgs;}) gtkThemeFromScheme;
in {
  gtk = {
    enable = true;
    # font = {
    #   name = config.fontProfiles.regular.family;
    #   size = 12;
    # };
    cursorTheme = lib.mkDefault {
      name = "Catppuccin-Mocha-Dark-Cursors";
      package = pkgs.catppuccin-cursors.mochaDark;
      size = 32;
    };
    theme = lib.mkDefault {
      name = config.colorScheme.slug;
      package = gtkThemeFromScheme {scheme = config.colorScheme;};
    };
    iconTheme = lib.mkDefault {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
  };
  services.xsettingsd = {
    enable = true;
    settings = {
      "Net/ThemeName" = config.gtk.theme.name;
      "Net/IconThemeName" = config.gtk.iconTheme.name;
    };
  };
  home.file.".config/gtk-4.0/gtk.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
  home.file.".config/gtk-4.0/gtk-dark.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
  home.file.".config/gtk-4.0/assets" = {
    recursive = true;
    source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
  };
}
