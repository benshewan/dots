{
  config,
  lib,
  ...
}: with config.lib.stylix.colors.withHashtag;
{
  config = lib.mkIf config.night-sky.desktops.hyprland.enable {
    services.dunst = {
      enable = true;
      # iconTheme = config.gtk.iconTheme;
      settings = {
          global.follow = "mouse";
          global.enable_recursive_icon_lookup = true;
          global.corner_radius = 6;

          # progressbar
          global.progress_bar_corner_radius = 6;
          urgency_low.highlight = base0E;
          urgency_normal.highlight = base0E;
          urgency_critical.highlight = base0E;

          # Frame
          global.frame_width = 1;
          global.gap_size = 2;
      };
    };
  };
}
