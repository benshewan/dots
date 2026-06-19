_: {
  flake.modules.homeManager."window-managers/mangowm" = {
    pkgs,
    lib,
    config,
    ...
  }: let
    mango = lib.getExe' config.wayland.windowManager.mango.package "mmsg";
    pidof = lib.getExe' pkgs.sysvtools "pidof";
    hyprlock = "${lib.getExe' pkgs.sysvtools "pidof"} hyprlock || ${lib.getExe config.programs.hyprlock.package}";
    # Standalone script for disabling monitors
    disable_all = pkgs.writeShellScript "disable-all-monitors" ''
      for output in $(${lib.getExe pkgs.wlr-randr} | ${lib.getExe pkgs.gawk} '/^[A-Za-z0-9]/ {print $1}'); do
        ${mango} dispatch disable_monitor,"$output"
      done
    '';

    # Standalone script for enabling monitors
    enable_all = pkgs.writeShellScript "enable-all-monitors" ''
      for output in $(${lib.getExe pkgs.wlr-randr} | ${lib.getExe pkgs.gawk} '/^[A-Za-z0-9]/ {print $1}'); do
        ${mango} dispatch enable_monitor,"$output"
      done
    '';
  in {
    services.swayidle = {
      enable = true;
      systemdTargets = ["graphical-session.target"];
      timeouts = [
        {
          timeout = 30;
          command = "if ${pidof} hyprlock; then ${disable_all}; fi";
          resumeCommand = "${enable_all}";
        }
        {
          timeout = 330;
          command = "if ${pidof} hyprlock; then systemctl suspend; fi";
        }
        {
          timeout = 1800;
          command = "${lib.getExe' pkgs.systemd "loginctl"} lock-session";
        }
        {
          timeout = 1830;
          command = "${disable_all}";
          resumeCommand = "${enable_all}";
        }
        {
          timeout = 2130;
          command = "systemctl suspend";
        }
      ];
      events = {
        lock = hyprlock;
        before-sleep = "${lib.getExe' pkgs.systemd "loginctl"} lock-session";
        after-resume = "${enable_all}";
      };
    };
  };
}
