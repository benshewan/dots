{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.desktops.gnome;
in {
  options.desktops.gnome = {
    enable = lib.mkEnableOption "gnome";
  };

  config = lib.mkIf cfg.enable {
    # Install GNOME
    services.xserver.desktopManager.gnome.enable = true;
    # Default DE
    services.xserver.displayManager.defaultSession = "gnome";
    # Login Manager
    services.xserver.displayManager.gdm = {
      enable = true;
      wayland = true;
    };

    # Disable certain defaults for GNOME
    environment.gnome.excludePackages =
      (with pkgs; [
        gnome-photos
        gnome-connections
        gnome-tour
      ])
      ++ (with pkgs.gnome; [
        cheese # webcam tool
        gnome-music
        # gnome-terminal
        # gedit # text editor
        epiphany # web browser
        # geary # email reader
        # evince # document viewer
        gnome-characters
        gnome-weather # weather app
        gnome-maps # maps app
        gnome-contacts # manage contacts
        gnome-software # software store
        yelp # help app
        gnome-font-viewer # manage fonts
        gnome-logs # view systemd logs
        # totem # video player
        tali # poker game
        iagno # go game
        hitori # sudoku game
        atomix # puzzle game
      ]);

    programs.kdeconnect = {
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };
    services.gnome.gnome-browser-connector.enable = true;
    services.gnome.sushi.enable = true;
    # Other GNOME Apps
    environment.systemPackages = with pkgs; [
      gnome.gnome-tweaks
    ];
  };
}
