{
  config,
  lib,
  inputs,
  ...
}: let
  inherit (lib) types mkIf mkDefault mkMerge;
  inherit (lib.night-sky) mkOpt;
  cfg = config.night-sky.theme;

  theme-paths = lib.snowfall.fs.get-directories ../stylix-themes;
  themes = lib.lists.forEach theme-paths (
    x:
      lib.lists.last (lib.strings.splitString "/" x)
  );
in {
  imports = [inputs.stylix.nixosModules.stylix];

  options.night-sky.theme = mkOpt (types.enum themes) "gruvbox" "Select one of these pre-configured themes to use.";

  config.stylix.enable = lib.mkDefault true;
  config.night-sky.home.extraOptions.stylix.targets.kde.enable = lib.mkDefault true;
}
