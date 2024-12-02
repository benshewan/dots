{inputs, lib, osConfig ? null,...}:{

  # imports = [inputs.stylix.homeManagerModules.stylix];
  imports = [  ] ++ lib.optional (osConfig == null) inputs.stylix.homeManagerModules.stylix;
}