{
  inputs,
  lib,
  osConfig ? null,
  ...
}: {
  imports = [] ++ lib.optional (osConfig == null) inputs.stylix.homeManagerModules.stylix;
  stylix.targets.qt.enable = true;
}
