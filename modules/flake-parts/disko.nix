{inputs, ...}: {
  flake-file.inputs.disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # Declarative disk partitioning, used by nixos-anywhere / disko at install
  # time and by NixOS at boot (it generates the fileSystems entries).
  #
  # A host opts in by resolving "disko" and providing a `disko.devices` layout,
  # e.g. machines/caelum/disko.nix. Without a layout the module is inert.
  flake.modules.nixos.disko = {
    imports = [inputs.disko.nixosModules.disko];
  };
}
