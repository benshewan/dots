{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.monitors;
in {
  options.monitors = mkOption {
    type = types.listOf (types.submodule {
      options = {
        name = mkOption {
          type = types.str;
          example = "DP-1";
        };
        primary = mkOption {
          type = types.bool;
          default = false;
        };
        width = mkOption {
          type = types.int;
          example = 1920;
        };
        height = mkOption {
          type = types.int;
          example = 1080;
        };
        refreshRate = mkOption {
          type = types.int;
          default = 60;
        };
        rotate = mkOption {
          type = types.int;
          default = 0;
          example = ''
            normal (no transforms) -> 0
            90 degrees -> 1
            180 degrees -> 2
            270 degrees -> 3
            flipped -> 4
            flipped + 90 degrees -> 5
            flipped + 180 degrees -> 6
            flipped + 270 degrees -> 7
          '';
        };
        scale = mkOption {
          type = types.float;
          default = 1.0;
        };
        x = mkOption {
          type = types.int;
          default = 0;
        };
        y = mkOption {
          type = types.int;
          default = 0;
        };
        enabled = mkOption {
          type = types.bool;
          default = true;
        };
        workspace = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        colorProfile = mkOption {
          type = types.enum ["auto" "srgb" "wide" "edid" "hdr" "hdredid"];
          default = "auto";
        };
        vrr = mkOption {
          type = types.enum [0 1 2 3];
          default = false;
          example = ''
            controls the VRR (Adaptive Sync) of your monitors. 0 - off, 1 - on, 2 - fullscreen only, 3 - fullscreen with video or game content type [0/1/2/3]
          '';
        };
      };
    });
    default = [];
  };
  config = {
    assertions = [
      {
        assertion =
          ((lib.length config.monitors) != 0)
          -> ((lib.length (lib.filter (m: m.primary) config.monitors)) == 1);
        message = "Exactly one monitor must be set to primary.";
      }
    ];
  };
}
