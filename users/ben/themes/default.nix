{ pkgs, ... }:
{
  # gtk = {
  #     enable = true;
  #     # font.name = "${custom.font} ${custom.fontsize}";
  #     iconTheme = {
  #         name = "Papirus-Dark";
  #         package = pkgs.catppuccin-papirus-folders;
  #     };
  #     # cursorTheme = {
  #     #     name = "${custom.cursor}";
  #     #     package = pkgs.numix-cursor-theme;
  #     # };
  #     theme = {
  #         name = "Catppuccin-Mocha-Standard-Blue-dark";
  #         package = pkgs.catppuccin-gtk.override { variant="mocha"; };
  #     };
  #     gtk3.extraConfig = {
  #         Settings = ''
  #             gtk-application-prefer-dark-theme=1
  #             '';
  #     };
  #     gtk4.extraConfig = {
  #         Settings = ''
  #             gtk-application-prefer-dark-theme=1
  #             '';
  #     };
  # };

  qt = {
    enable = true;
    platformTheme = "kde";
    style = {
      package = pkgs.catppuccin-kde.override { flavour = [ "mocha" ]; };
      name = "Catppuccin-Mocha-Blue";
    };
  };
}
