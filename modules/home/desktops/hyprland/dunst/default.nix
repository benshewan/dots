{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.night-sky.desktops.hyprland.enable {
    services.dunst = {
      enable = true;
      # iconTheme = config.gtk.iconTheme;
      settings = {
        global.follow = "mouse";
      };
    };
  };
}
