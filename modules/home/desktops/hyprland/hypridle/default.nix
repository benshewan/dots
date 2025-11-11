{
  config,
  pkgs,
  lib,
  ...
}: let
  hyprctl = lib.getExe' config.wayland.windowManager.hyprland.package "hyprctl";
  hyprlock = "${lib.getExe' pkgs.sysvtools "pidof"} hyprlock || ${lib.getExe config.programs.hyprlock.package}";
in {
  config = lib.mkIf config.night-sky.desktops.hyprland.enable {
    services.hypridle = {
      enable = true;
      settings.listener = [
        {
          timeout = 30;
          on-timeout = "${lib.getExe' pkgs.sysvtools "pidof"} hyprlock && ${hyprctl} dispatch dpms off";
          on-resume = "${hyprctl} dispatch dpms on";
        }
        {
          timeout = 330;
          on-timeout = "${lib.getExe' pkgs.sysvtools "pidof"} hyprlock && systemctl suspend";
          on-resume = "${hyprctl} dispatch dpms on";
        }
        {
          timeout = 1800;
          on-timeout = "${lib.getExe' pkgs.systemd "loginctl"} lock-session";
        }
        {
          timeout = 1830;
          on-timeout = "${hyprctl} dispatch dpms off";
          on-resume = "${hyprctl} dispatch dpms on";
        }
        {
          timeout = 2130;
          on-timeout = "systemctl suspend";
        }
      ];

      settings.general = {
        lock_cmd = hyprlock;
        unlock_cmd = "";
        after_sleep_cmd = "${hyprctl} dispatch dpms on";
        before_sleep_cmd = "${lib.getExe' pkgs.systemd "loginctl"} lock-session";
        inhibit_sleep = 3;
      };
    };
  };
}
