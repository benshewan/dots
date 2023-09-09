{ pkgs, ... }:
{
  programs.waybar.enable = true;
  programs.hyprland = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    bluetuith
    wofi
    swaybg
    libsForQt5.dolphin
    libsForQt5.baloo
    libsForQt5.dolphin-plugins
    libsForQt5.kdegraphics-thumbnailers
    libsForQt5.kio
    libsForQt5.kio-extras
    taglib
    ffmpegthumbnailer
    ark
   ];

  # KDE Connect plus some magic to get chromium browser integration working
  programs.kdeconnect.enable = true;
  environment.etc."chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json".source = "${pkgs.plasma-browser-integration}/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json";
}
