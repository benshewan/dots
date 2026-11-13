{inputs, ...}: {
  flake-file.inputs.disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # Declarative disk partitioning, used by nixos-anywhere / disko at install
  # time and by NixOS at boot (it generates the fileSystems entries).
  #
  # A host opts in by resolving a layout from modules/disk-layouts (e.g.
  # "disk-layouts/luks-btrfs", which imports this module itself) and setting
  # its options. Without a layout the module is inert.
  flake.modules.nixos.disko = {
    imports = [inputs.disko.nixosModules.disko];
  };
}
