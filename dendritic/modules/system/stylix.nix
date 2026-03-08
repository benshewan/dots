{
  inputs,
  lib,
  ...
}: {
  flake.modules.nixos.system = {
    imports = [inputs.stylix.nixosModules.stylix];
    stylix.enable = lib.mkDefault true;
  };
}
