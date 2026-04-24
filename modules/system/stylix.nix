{
  inputs,
  lib,
  ...
}: {
  flake-file.inputs = {
    stylix.url = "github:danth/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
  };
  flake.modules.nixos.system = {
    imports = [inputs.stylix.nixosModules.stylix];
    stylix.enable = lib.mkDefault true;
  };
}
