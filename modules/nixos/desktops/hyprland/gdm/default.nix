{
  config,
  lib,
  ...
}: let
  cfg = config.night-sky.desktops.hyprland.gdm;
in {
  options.night-sky.desktops.hyprland.gdm = lib.night-sky.mkOpt lib.types.bool false "Use GDM as Hyprland's display manager.";

  config = lib.mkIf cfg {
    services.xserver.displayManager.gdm = {
      enable = true;
      wayland = true;
    };
  };
}
