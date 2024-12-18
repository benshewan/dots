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

  config =
    lib.mkIf cfg.enable {
      programs = {
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
    # // (
    #   if isLinux then {
    #     programs.plasma.enable = true;
    #     programs.plasma.configFile.kdeglobals.General.TerminalApplication.value = toString (lib.getExe pkgs.kitty);
    #   } else {}
    # ));
}
