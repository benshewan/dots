{
  config,
  lib,
  inputs,
  ...
} @ arguments: let
  inherit (lib) types mkIf mkDefault mkMerge;
  inherit (lib.night-sky) mkOpt;
  cfg = config.night-sky.theme;

  theme-paths = lib.snowfall.fs.get-directories (lib.snowfall.fs.get-file "themes");
  themes = lib.lists.forEach theme-paths (
    x:
      lib.lists.last (lib.strings.splitString "/" x)
  );
  themeFiles = lib.snowfall.fs.get-nix-files-recursive (lib.snowfall.fs.get-file "themes");
in {
  imports = [inputs.stylix.nixosModules.stylix] ++ builtins.map (file: import file arguments) themeFiles;
  
  options.night-sky.theme = mkOpt (types.enum themes) "gruvbox" "Select one of these pre-configured themes to use.";

  config = {
    stylix.enable = lib.mkDefault true;
    night-sky.home.extraOptions.stylix.targets.kde.enable = lib.mkDefault true;
  };
}
