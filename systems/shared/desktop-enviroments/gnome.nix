{ pkgs, ... }:
{
  # Install GNOME
  services.xserver.desktopManager.gnome.enable = true;
  # Default DE
  services.xserver.displayManager.defaultSession = "gnome";

  # Disable certain defaults for GNOME
  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-connections
    gnome-tour
  ]) ++ (with pkgs.gnome; [
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
    totem # video player
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
  ]);

  # Enable xdg portal
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
    ];
  };

  # Other GNOME Apps
  environment.systemPackages = with pkgs; [
    gnome.gnome-tweaks
  ];
}
