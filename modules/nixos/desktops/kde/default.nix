{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.night-sky.desktops.kde;
in {
  options.night-sky.desktops.kde = {
    enable = lib.mkEnableOption "kde";
  };

  config = lib.mkIf cfg.enable {
    # Install KDE
    services.desktopManager.plasma6.enable = true;
    # Default DE
    services.displayManager.defaultSession = "plasma";
    # Login Manager
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      wayland.compositor = "kwin";
      enableHidpi = true;
    };

    # Disable certain defaults for KDE
    environment.plasma6.excludePackages = with pkgs.libsForQt5; [
      elisa
      gwenview
      okular
      oxygen
      khelpcenter
      # konsole
      # plasma-browser-integration
      # print-manager
    ];

    environment.systemPackages = with pkgs; [
      # latte-dock # Fancy docks and panels for KDE
    ];

    environment.sessionVariables = {
      GTK_USE_PORTAL = "1";
    };

    # Enable xdg portal
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-kde
      ];
    };

    # KDE Connect plus some magic to get chromium browser integration working
    programs.kdeconnect.enable = true;
    # environment.etc."chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json".source = "${pkgs.plasma-browser-integration}/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json";
  };
}
