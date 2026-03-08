{
  config,
  lib,
  ...
}: {
  flake.modules.nixos."display-managers/tuigreet" = {pkgs, ...}: {
    services.xserver.displayManager.lightdm.enable = lib.mkDefault false;
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
