{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: let
  cfg = config.night-sky.desktops.hyprland.greetd;
in {
  options.night-sky.desktops.hyprland.greetd = lib.night-sky.mkOpt lib.types.bool false "Use Greetd as Hyprland's display manager.";

  # Taken from https://github.com/sjcobb2022/nixos-config/blob/main/hosts/common/optional/greetd.nix
  config = lib.mkIf cfg {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = ''${lib.getExe pkgs.tuigreet} --time --remember --remember-session --asterisks --asterisks-char • --theme "border=magenta;text=cyan;prompt=green;time=red;action=blue;button=yellow;container=black;input=red"'';
          user = "greeter";
        };
      };
      useTextGreeter = true;
    };
  };
}
