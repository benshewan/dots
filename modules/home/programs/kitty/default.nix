{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: let
  inherit (pkgs.stdenv) isLinux;
  cfg = config.night-sky.programs.kitty;
in {
  imports = [] ++ lib.optional isLinux inputs.plasma-manager.homeManagerModules.plasma-manager;
  options.night-sky.programs.kitty = {
    enable = lib.mkEnableOption "kitty";
  };

  config = lib.mkIf cfg.enable {
    programs =
      (lib.mkIf isLinux {
        plasma.enable = true;
        plasma.configFile.kdeglobals.General.TerminalApplication.value = toString (lib.getExe pkgs.kitty);
      })
      // {
        kitty = {
          enable = true;
          package = pkgs.kitty;
          shellIntegration.enableFishIntegration = true;
          settings = {
            scrollback_lines = 10000;
            confirm_os_window_close = 0;
          };
        };
      };
  };
}
