_: {
  flake.modules.homeManager."window-managers/hyprland" = {
    pkgs,
    lib,
    config,
    ...
  }: {
    services.dunst = {
      enable = true;
      # iconTheme = config.gtk.iconTheme;
      settings = {
        global.follow = "mouse";
        global.enable_recursive_icon_lookup = true;
        global.corner_radius = 6;

        # progressbar
        global.progress_bar_corner_radius = 6;

        # Frame
        global.frame_width = 1;
        global.gap_size = 2;
      };
    };
  };
}
