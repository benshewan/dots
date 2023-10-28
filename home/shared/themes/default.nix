{inputs, ...}: {
  imports = [
    inputs.nix-colors.homeManagerModules.default
    # KDE doesn't play nice with this
    ./gtk.nix
    # ./qt.nix
  ];
}
