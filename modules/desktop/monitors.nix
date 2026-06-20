{...}: {
  # Home Manager
  # --------------------------------------------------------------------------------
  flake.modules.homeManager."monitors" = {
    pkgs,
    lib,
    config,
    ...
  }: let
    inherit (lib) mkOption types;
    cfg = config.monitors;

    # Parse a monitor identifier ("name:X" | "desc:X" | "serial:X" | bare name)
    # into { match = "name"|"desc"|"serial"; value = "..."; }. A bare identifier
    # (no recognized prefix) is treated as a connector name (match = "name").
    parseMonitorName = name: let
      parts = lib.splitString ":" name;
      head = builtins.head parts;
      value = lib.concatStringsSep ":" (builtins.tail parts);
    in
      if builtins.length parts > 1 && builtins.elem head ["name" "desc" "serial"]
      then {match = head; inherit value;}
      else {match = "name"; value = name;};
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
            default = 0;
            example = ''
              controls the VRR (Adaptive Sync) of your monitors. 0 - off, 1 - on, 2 - fullscreen only, 3 - fullscreen with video or game content type [0/1/2/3]
            '';
          };
        };
      });
      default = [];
    };
    config = {
      # Shared helpers so a single `monitors` list drives both MangoWM and Hyprland.
      # MangoWM matches "name:X" / "serial:X" / "desc:X" explicitly.
      # Hyprland matches bare connector names or "desc:X"; it cannot match by
      # serial, so serial:* resolves to null (callers should skip those entries).
      lib.monitors = {
        parseName = parseMonitorName;
        mangoName = name: let p = parseMonitorName name; in "${p.match}:${p.value}";
        hyprName = name: let p = parseMonitorName name; in
          if p.match == "serial"
          then null
          else if p.match == "name"
          then p.value
          else "${p.match}:${p.value}";
      };

      assertions = [
        {
          assertion =
            ((lib.length config.monitors) != 0)
            -> ((lib.length (lib.filter (m: m.primary) config.monitors)) == 1);
          message = "Exactly one monitor must be set to primary.";
        }
      ];
    };
  };
}
