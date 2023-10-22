{inputs, ...}: {
  imports = [
    inputs.nix-colors.homeManagerModules.default
    ./gtk.nix
    ./gt.nix
  ];
}
