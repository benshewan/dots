{
  config,
  lib,
  pkgs,
  ...
}: let
  hyprctl = lib.getExe' config.wayland.windowManager.hyprland.package "hyprctl";
  swaylock = "${lib.getExe config.programs.swaylock.package} -f";
in {
  services.swayidle = {
    enable = true;
    systemdTarget = "graphical-session.target";
    timeouts = [
      {
        timeout = 10;
        command = "if ${lib.getExe' pkgs.toybox "pgrep"} -x swaylock; then ${hyprctl} dispatch dpms off; fi";
        resumeCommand = "${hyprctl} dispatch dpms on";
      }
      {
        timeout = 1800;
        command = swaylock;
      }
      {
        timeout = 1830;
        command = "${hyprctl} dispatch dpms off";
        resumeCommand = "${hyprctl} dispatch dpms on";
      }
    ];
    events = [
      {
        event = "before-sleep";
        command = swaylock;
      }
      {
        event = "lock";
        command = swaylock;
      }
      {
        event = "after-resume";
        command = "${hyprctl} dispatch dpms on";
      }
    ];
  };
}
