{...}: {
  imports = [
    ./packages.nix
    ./services.nix
    ./hardware.nix
    ../../shared/nixos
  ];
}
