{
  inputs,
  lib,
  ...
}: {
  flake-file.inputs = {
    stylix.url = "github:danth/stylix";
  };
  flake.modules.nixos.system = {
    imports = [inputs.stylix.nixosModules.stylix];
    stylix.enable = lib.mkDefault true;
  };
}
