{
  lib,
  pkgs,
  inputs,
  osConfig ? {},
  ...
}: let
  inherit (pkgs.stdenv) isDarwin;
in {
  imports = [] ++ lib.optional isDarwin inputs.mac-app-util.homeManagerModules.default;

  home.stateVersion = lib.mkDefault (
    if (osConfig != {} && osConfig.system.stateVersion)
    then osConfig.system.stateVersion
    else "23.11"
  );
  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
