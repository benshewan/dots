{inputs, ...}: {
  imports = [
    inputs.nix-colors.homeManagerModules.default
    ./gtk.nix
    ./qt.nix
  ];
}
