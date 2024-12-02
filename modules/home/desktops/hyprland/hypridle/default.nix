{
  config,
  pkgs,
  lib,
  ...
}: let
  hyprctl = lib.getExe' config.wayland.windowManager.hyprland.package "hyprctl";
  hyprlock = "if ! ${lib.getExe' pkgs.toybox "pgrep"} -x hyprlock; then ${lib.getExe config.programs.hyprlock.package}; fi";

in {
  config = lib.mkIf config.night-sky.desktops.hyprland.enable {
    services.hypridle = {
      enable = true;
      settings.listener = [
        {
          timeout = 30;
          on-timeout = "if ${lib.getExe' pkgs.toybox "pgrep"} -x hyprlock; then ${hyprctl} dispatch dpms off; fi";
          on-resume = "${hyprctl} dispatch dpms on";
        }
        {
          timeout = 1800;
          on-timeout = hyprlock;
        }
        {
          timeout = 1830;
          on-timeout = "${hyprctl} dispatch dpms off";
          on-resume = "${hyprctl} dispatch dpms on";
        }
      ];

      settings.general = {
        lock_cmd = hyprlock;
        unlock_cmd = "";
        after_sleep_cmd = "${hyprctl} dispatch dpms on";
        before_sleep_cmd = hyprlock;
        ignore_dbus_inhibit = false;
      };
    };
  };
}
