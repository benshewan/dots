{config, ...}: {
  services.dunst = {
    enable = true;
    # iconTheme = config.gtk.iconTheme;
    settings = {
      global.follow = "mouse";
    };
  };
}
