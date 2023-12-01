{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.stylix.nixosModules.stylix

    ../both
  ];

  # Fixing theme
  # environment.sessionVariables = {
  #   QT_QPA_PLATFORMTHEME = "qt5ct";
  # };
  qt = {
    enable = true;
    platformTheme = "qt5ct";
    # style = {
    #   package = pkgs.catppuccin-kvantum;
    #   name = "Catppuccin-Macchiato-Blue";
    # };
  };
}
