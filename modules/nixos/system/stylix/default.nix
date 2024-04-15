{inputs, ...}: {
  imports = [inputs.stylix.nixosModules.stylix];
  stylix.image = ../../../../wallpapers/gruvbox/gruvbox-dark-blue.png;
}
