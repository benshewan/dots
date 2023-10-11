{
  pkgs,
  inputs,
  ...
}: let
  theme-gtk = pkgs.catppuccin-gtk.override {
    accents = ["blue"];
    size = "standard"; # compact
    tweaks = [];
    variant = "mocha";
  };
  theme-gtk-name = "Catppuccin-Mocha-Standard-Blue-dark";
in {
  imports = [inputs.nix-colors.homeManagerModules.default];
  colorScheme = inputs.nix-colors.colorSchemes.catppuccin-mocha;
  gtk = {
    enable = true;
    # font.name = "${custom.font} ${custom.fontsize}";
    iconTheme = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
    };
    cursorTheme = {
      name = "Catppuccin-Mocha-Dark-Cursors";
      package = pkgs.catppuccin-cursors.mochaDark;
      size = 32;
    };
    theme = {
      name = theme-gtk-name;
      package = theme-gtk;
    };
    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
  };

  home.file.".config/gtk-4.0/gtk.css".source = "${theme-gtk}/share/themes/${theme-gtk-name}/gtk-4.0/gtk.css";
  home.file.".config/gtk-4.0/gtk-dark.css".source = "${theme-gtk}/share/themes/${theme-gtk-name}/gtk-4.0/gtk-dark.css";
  home.file.".config/gtk-4.0/assets" = {
    recursive = true;
    source = "${theme-gtk}/share/themes/${theme-gtk-name}/gtk-4.0/assets";
  };

  # home.packages = with pkgs;[
  #   qt5ct
  #   lightly-qt
  # ];

  qt = {
    enable = true;
    platformTheme = "gtk2";
    style.name = "gtk2";
  };
}
