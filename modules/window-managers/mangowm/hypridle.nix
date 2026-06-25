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
    services.hypridle = {
      enable = true;
      settings.listener = [
        # {
        #   timeout = 30;
        #   on-timeout = "if ${pidof} hyprlock; then ${disable_all}; fi";
        #   on-resume = "${enable_all}";
        # }
        {
          timeout = 330;
          on-timeout = "if ${pidof} hyprlock; then systemctl suspend; fi";
        }
        {
          timeout = 1800;
          on-timeout = "${lib.getExe' pkgs.systemd "loginctl"} lock-session";
        }
        # {
        #   timeout = 1830;
        #   on-timeout = "${disable_all}";
        #   on-resume = "${enable_all}";
        # }
        {
          timeout = 2130;
          on-timeout = "systemctl suspend";
        }
      ];

      settings.general = {
        lock_cmd = hyprlock;
        unlock_cmd = "";
        after_sleep_cmd = "${enable_all}";
        before_sleep_cmd = "${lib.getExe' pkgs.systemd "loginctl"} lock-session";
        inhibit_sleep = 3;
      };
    };
  };
}
