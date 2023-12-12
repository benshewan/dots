{
  lib,
  pkgs,
  outputs,
  inputs,
  config,
  ...
}: {
  imports = [
    ./packages.nix
    ./services.nix
    ./hardware.nix
    ../../shared/nixos
  ];
  # ++ (builtins.attrValues outputs.nixosModules);
}
