{outputs, ...}: {
  imports = [
    ./packages.nix
    ./programs
  ];
  nixpkgs.overlays = [outputs.overlays.additions];
}
