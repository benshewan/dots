{
  config,
  lib,
  pkgs,
  ...
}: let
  hyprctl = lib.getExe' config.wayland.windowManager.hyprland.package "hyprctl";
  swaylock = "if ! ${lib.getExe' pkgs.toybox "pgrep"} -x swaylock; then ${lib.getExe config.programs.swaylock.package} -f; fi";
in {
  services.swayidle = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    timeouts = [
      {
        timeout = 30;
        command = "if ${lib.getExe' pkgs.toybox "pgrep"} -x swaylock; then ${hyprctl} dispatch dpms off; fi";
        resumeCommand = "${hyprctl} dispatch dpms on";
      }
      # {
      #   timeout = 630;
      #   command = "if ${lib.getExe' pkgs.toybox "pgrep"} -x swaylock; then systemctl suspend-then-hibernate; fi";
      # }
      {
        timeout = 1800;
        command = swaylock;
      }
      {
        timeout = 1830;
        command = "${hyprctl} dispatch dpms off";
        resumeCommand = "${hyprctl} dispatch dpms on";
      }
      # {
      #   timeout = 2430;
      #   command = "systemctl suspend-then-hibernate";
      # }
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
