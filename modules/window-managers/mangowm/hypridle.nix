_: {
  flake.modules.homeManager."window-managers/mangowm" = {
    pkgs,
    lib,
    config,
    ...
  }: let
    pidof = lib.getExe' pkgs.sysvtools "pidof";
    loginctl = lib.getExe' pkgs.systemd "loginctl";
    hyprlock = "${pidof} hyprlock || ${lib.getExe config.programs.hyprlock.package}";
  in {
    services.hypridle = {
      enable = true;
      settings.listener = [
        {
          timeout = 330;
          on-timeout = "if ${pidof} hyprlock; then systemctl suspend; fi";
        }
        {
          timeout = 1800;
          on-timeout = "${loginctl} lock-session";
        }
        {
          timeout = 2130;
          on-timeout = "systemctl suspend";
        }
      ];

      settings.general = {
        lock_cmd = hyprlock;
        unlock_cmd = "";
        # Wake the external outputs, but keep the internal panel off when the
        # lid is shut. Enabling *every* output on resume is what used to make
        # the laptop screen reappear while docked with the lid closed.
        after_sleep_cmd = "${config.lib.mango.lid.wake}";
        before_sleep_cmd = "${loginctl} lock-session";
        inhibit_sleep = 3;
      };
    };
  };
}
