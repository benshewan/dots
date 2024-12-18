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

  home.stateVersion = lib.mkDefault (lib.mkIf (osConfig != {} && osConfig.system.stateVersion) osConfig.system.stateVersion // "23.11");
  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
