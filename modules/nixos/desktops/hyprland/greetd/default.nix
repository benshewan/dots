{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: let
  cfg = config.night-sky.desktops.hyprland.greetd;
  tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
in {
  options.night-sky.desktops.hyprland.greetd = lib.night-sky.mkOpt lib.types.bool false "Use Greetd as Hyprland's display manager.";

  # Taken from https://github.com/sjcobb2022/nixos-config/blob/main/hosts/common/optional/greetd.nix
  config = lib.mkIf cfg {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${tuigreet} --time --remember --remember-session --asterisks --asterisks-char •";
          user = "greeter";
        };
      };
    };

    # https://discourse.nixos.org/t/login-keyring-did-not-get-unlocked-hyprland/40869/10
    environment.variables.XDG_RUNTIME_DIR = "/run/user/$UID"; # set the runtime directory

    # this is a life saver.
    # literally no documentation about this anywhere.
    # might be good to write about this...
    # https://www.reddit.com/r/NixOS/comments/u0cdpi/tuigreet_with_xmonad_how/

    systemd.services.greetd.serviceConfig = {
      Type = "idle";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal"; # Without this errors will spam on screen
      # Without these bootlogs will spam on screen
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
    };
  };
}
