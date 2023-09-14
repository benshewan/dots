{ pkgs, config, lib, ... }:
# let
# exec "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP"
# input "type:touchpad" {
#   tap enabled
# }
# seat seat0 xcursor_theme Bibata-Modern-Classic 24

# xwayland disable

# bindsym XF86MonBrightnessUp exec light -A 5
# bindsym XF86MonBrightnessDown exec light -U 5
# bindsym Print exec ${lib.getExe pkgs.grim} /tmp/regreet.png
# bindsym Mod4+shift+e exec swaynag \
#   -t warning \
#   -m 'What do you want to do?' \
#   -b 'Poweroff' 'systemctl poweroff' \
#   -b 'Reboot' 'systemctl reboot'
#   greetdHyprlandConfig = pkgs.writeText "greetd-hyprland-config" ''
#     exec-once = "${lib.getExe pkgs.greetd.regreet}; hyprctl dispatch exit"
#   '';
# in
# services.greetd = {
#   enable = true;
#   settings.default_session = {
#     command = "${config.programs.hyprland.package}/bin/Hyprland --config ${greetdHyprlandConfig}";
#     user = "greeter";
#   };
# };
# programs.regreet = {
#   enable = true;
#   settings = {
#     background = {
#       path = ../../../wallpapers/nix-black-4k.png;
#       fit = "Cover";
#     };
#     # GTK = {
#     #   cursor_theme_name = "Bibata-Modern-Classic";
#     #   font_name = "Jost * 12";
#     #   icon_theme_name = "Papirus-Dark";
#     #   theme_name = "Catppuccin-Mocha-Compact-Mauve-Dark";
#     # };
#   };
# };
{
  programs.waybar.enable = true;
  programs.hyprland = {
    enable = true;
  };
  services.xserver.displayManager.gdm = {
    enable = true;
    wayland = true;
  };
  services.gnome.gnome-keyring.enable = true; # Store secrets securely (Wifi passwords,git tokens, etc...)

  environment.systemPackages = (with pkgs; [
    bluetuith # TUI Bluetooth manager
    wofi # Runner
    swaybg # Wallpaper ultility
    hyprpicker # Color picker
    wl-clipboard
    copyq # Clipboard
    libsForQt5.polkit-kde-agent # Graphical root elevation
    gparted # Test polkit

    # Dolphin and assorted dependencies for it
    taglib
    ffmpegthumbnailer
  ]) ++ (with pkgs.libsForQt5; [
    dolphin
    ark
    baloo
    dolphin-plugins
    kdegraphics-thumbnailers
    kio
    kio-extras
    breeze-icons
  ]);

  # KDE Connect plus some magic to get chromium browser integration working
  programs.kdeconnect.enable = true;
  environment.etc."chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json".source = "${pkgs.plasma-browser-integration}/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json";
}
