{config, ...}: {
  services.dunst = {
    enable = true;
    iconTheme = config.gtk.iconTheme;
  };
}
