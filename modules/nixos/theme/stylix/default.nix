{
  config,
  lib,
  inputs,
  ...
}: let
  inherit (lib) types mkIf mkDefault mkMerge;
  inherit (lib.night-sky) mkOpt;
  cfg = config.night-sky.theme;

  themes = ["gruvbox" "catppuccin"];
in {
  imports = [inputs.stylix.nixosModules.stylix];
  options.night-sky.theme = mkOpt (types.enum themes) "gruvbox" "Select one of these pre-configured themes to use.";
}
