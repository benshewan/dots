{
  user = import ./user.nix;
  boot = import ./boot.nix;
  shell = import ./shell.nix;
  nix = import ./nix.nix;
  networking = import ./networking.nix;
  kernel = import ./kernel.nix;
  fonts = import ./fonts.nix;
  stylix = import ./stylix.nix;
  utilites = import ./utilites.nix;
}
