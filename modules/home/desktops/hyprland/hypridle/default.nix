{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: let
  hyprctl = lib.getExe' config.wayland.windowManager.hyprland.package "hyprctl";
  hyprlock = "if ! ${lib.getExe' pkgs.toybox "pgrep"} -x hyprlock; then ${lib.getExe config.programs.hyprlock.package} -f; fi";
in {
  imports = [
    inputs.hypridle.homeManagerModules.default
  ];

  config = lib.mkIf config.wayland.windowManager.hyprland.enable {
    services.hypridle = {
      enable = true;
      listeners = [
        {
          timeout = 30;
          onTimeout = "if ${lib.getExe' pkgs.toybox "pgrep"} -x hyprlock; then ${hyprctl} dispatch dpms off; fi";
          onResume = "${hyprctl} dispatch dpms on";
        }
        {
          timeout = 1800;
          onTimeout = hyprlock;
        }
        {
          timeout = 1830;
          onTimeout = "${hyprctl} dispatch dpms off";
          onResume = "${hyprctl} dispatch dpms on";
        }
      ];

      lockCmd = hyprlock;
      unlockCmd = "";

      afterSleepCmd = "${hyprctl} dispatch dpms on";
      beforeSleepCmd = hyprlock;
      ignoreDbusInhibit = false;
    };
  };
}
