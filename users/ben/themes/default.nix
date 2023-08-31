{ pkgs, ... }:
let
  theme-gtk = pkgs.catppuccin-gtk.override {
    accents = [ "blue" ];
    size = "standard"; # compact
    tweaks = [ ];
    variant = "mocha";
  };
  theme-gtk-name = "Catppuccin-Mocha-Standard-Blue-dark";
in
{
  gtk = {
    enable = true;
    # font.name = "${custom.font} ${custom.fontsize}";
    # iconTheme = {
    #   name = "Papirus-Dark";
    #   package = pkgs.catppuccin-papirus-folders;
    # };
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

  qt = {
    enable = true;
    platformTheme = "gnome";
    style.name = "adwaita-dark";
    # style = {
    #   package = pkgs.catppuccin-kde.override { flavour = [ "mocha" ]; };
    #   name = "Catppuccin-Mocha-Blue";
    # };
  };
}
