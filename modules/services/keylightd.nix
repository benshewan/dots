{...}: {
  flake.modules.nixos."services/keylightd" = {
    pkgs,
    lib,
    config,
    ...
  }:
    with lib; let
      cfg = config.services.keylightd;
    in {
      options.services.keylightd = {
        enable = mkEnableOption "keylightd";

        package = mkPackageOption pkgs.local "keylightd" {};

        brightness = mkOption {
          type = types.int;
          example = 30;
          default = 30;
        };

        timeout = mkOption {
          type = types.int;
          example = 10;
          default = 10;
        };

        powerLed = mkOption {
          type = types.bool;
          example = true;
          default = true;
        };
      };

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [cfg.package]; # for the CLI
        systemd.packages = [cfg.package];
        systemd.services = {
          keylightd = {
            description = "keylightd is a small system daemon for Framework laptops that listens to keyboard and touchpad input, and turns on the keyboard backlight while either is being used.";
            unitConfig = {
              StartLimitBurst = 5;
              StartLimitIntervalSec = 500;
            };
            serviceConfig = {
              # ${mkIf cfg.powerLed "--power"}
              Type = "exec";
              ExecStart = "${cfg.package}/bin/keylightd --power --brightness ${toString cfg.brightness} --timeout ${toString cfg.timeout} ";
              Restart = "on-failure";
              RestartSec = "1s";
            };
            wantedBy = ["multi-user.target"];
          };
        };
      };
    };
}
