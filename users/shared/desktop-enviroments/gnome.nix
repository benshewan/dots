{ pkgs, lib, config, inputs, ... }:
let
  toWorkspace = w: apps:
    map (name: "${name}.desktop:${toString w}") apps;
  hexToRGBString = inputs.nix-colors.lib.conversions.hexToRGBString;
  colors = config.colorScheme.colors;
in
rec {
  # GNOME Extensions
  home.packages = with pkgs.gnomeExtensions; [
    user-themes
    dash-to-dock
    blur-my-shell
    space-bar
    auto-move-windows
    appindicator
    gsconnect
  ];

  # GNOME Settings
  dconf.settings = with lib.hm.gvariant; {

    "org/gnome/shell" = {
      # Extension Settings
      disable-user-extensions = false;
      enabled-extensions = map (extension: extension.extensionUuid) home.packages;
      disabled-extensions = [ ];
      # Pinned Apps
      favorite-apps = [
        "firefox.desktop"
        "org.gnome.Nautilus.desktop"
        "codium.desktop"
        "kitty.desktop"
      ];
    };

    # Mouse Settings
    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "flat";
      speed = 0;
    };
    "org/gnome/desktop/wm/preferences" = {
      resize-with-right-button = true;
      button-layout = "icon:close";
    };

    # Time before screen goes dark (seconds)
    "org/gnome/desktop/session" = {
      idle-delay = mkUint32 900;
    };

    # i3-like workspace indicator
    "org/gnome/shell/extensions/space-bar/behavior" = {
      show-empty-workspaces = false;
      position = "left";
      position-index = 0;
      scroll-wheel = "disabled";
      smart-workspace-names = false;
    };

    "org/gnome/shell/extensions/space-bar/appearance" = {
      workspaces-bar-padding = mkUint32 12;
      workspace-margin = mkUint32 4;
      active-workspace-text-color = "rgb(${hexToRGBString "," colors.base01})";
      active-workspace-background-color = "rgb(${hexToRGBString "," colors.base0D})";
      inactive-workspace-border-radius = mkUint32 4;
      inactive-workspace-font-weight = "700";
      inactive-workspace-background-color = "rgba(${hexToRGBString "," colors.base02},0.0)";
      inactive-workspace-text-color = "rgb(${hexToRGBString "," colors.base04})";
    };

    "org/gnome/shell/extensions/space-bar/shortcuts" = {
      enable-activate-workspace-shortcuts = false;
      enable-move-to-workspace-shortcuts = false;
      activate-empty-key = [ ];
      activate-previous-key = [ ];
      open-menu = [ ];
    };

    # Visual Settings
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file://" + ../../../wallpapers/nix-black-4k.png;
      picture-uri-dark = "file://" + ../../../wallpapers/nix-black-4k.png;
    };
    "org/gnome/shell/extensions/user-theme" = {
      name = config.gtk.theme.name;
    };
    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 10;
      workspace-names = [
        "1: web"
        "2: dev"
        "3: notes"
        "4: social"
        "5"
        "6"
        "7"
        "8"
        "9"
        "10: tmp"
      ];
    };

    "org/gnome/shell/extensions/auto-move-windows" = {
      application-list =
        # 1. Web (Browsers)
        (toWorkspace 1 [
          "vivaldi"
          "firefox-devedition"
        ]) ++

        # 2. Dev (Terminals, editors, ..etc)
        (toWorkspace 2 [
          "codium"
          "org.gnome.Console"
          "org.kitty"
        ]) ++

        # 3. Notes (Obsidian)
        (toWorkspace 3 [
          "obsidian"
        ]) ++

        # 4. Social (Slack, Discord ..etc)
        (toWorkspace 4 [
          "discord"
          "slack"
        ]) ++

        # 10. Temporarily access (Spotify, 1Password, Settings ..etc)
        (toWorkspace 10 [
          "1password"
          "bluetooth-sendto"
          "gcm-calibrate"
          "gcm-picker"
          "gnome-applications-panel"
          "gnome-background-panel"
          "gnome-bluetooth-panel"
          "gnome-color-panel"
          "gnome-datetime-panel"
          "gnome-default-apps-panel"
          "gnome-diagnostics-panel"
          "gnome-display-panel"
          "gnome-firmware-security-panel"
          "gnome-info-overview-panel"
          "gnome-keyboard-panel"
          "gnome-location-panel"
          "gnome-microphone-panel"
          "gnome-mouse-panel"
          "gnome-multitasking-panel"
          "gnome-network-panel"
          "gnome-notifications-panel"
          "gnome-online-accounts-panel"
          "gnome-power-panel"
          "gnome-printers-panel"
          "gnome-region-panel"
          "gnome-removable-media-panel"
          "gnome-screen-panel"
          "gnome-search-panel"
          "gnome-sharing-panel"
          "gnome-sound-panel"
          "gnome-system-monitor-kde"
          "gnome-thunderbolt-panel"
          "gnome-universal-access-panel"
          "gnome-usage-panel"
          "gnome-user-accounts-panel"
          "gnome-wacom-panel"
          "gnome-wifi-panel"
          "gnome-wwan-panel"
          "org.gnome.ColorProfileViewer"
          "org.gnome.Evince-previewer"
          "org.gnome.Extensions"
          "org.gnome.Settings"
          "org.gnome.Shell.Extensions"
          "org.gnome.tweaks"
          "spotify"
        ]);
    };
  };
}
