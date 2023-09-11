{ pkgs, ... }:
{
  # Install KDE
  services.xserver.desktopManager.plasma5.enable = true;
  # Default DE
  services.xserver.displayManager.defaultSession = "plasmawayland";
  # Login Manager
  services.xserver.displayManager.gdm = {
    enable = true;
    wayland = true;
  };

  # Disable certain defaults for KDE
  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
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
    lightly-qt # KDE Application Theme
    latte-dock # Fancy docks and panels for KDE
  ];

  # Enable xdg portal
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-kde
    ];
  };

  # KDE Connect plus some magic to get chromium browser integration working
  programs.kdeconnect.enable = true;
  environment.etc."chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json".source = "${pkgs.plasma-browser-integration}/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json";
}
