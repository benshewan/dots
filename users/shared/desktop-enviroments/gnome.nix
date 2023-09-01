{ pkgs, lib, config, ... }:
rec {
  # GNOME Extensions
  home.packages = with pkgs.gnomeExtensions; [
    user-themes
    vitals
    dash-to-dock
    blur-my-shell
    appindicator
  ];

  # GNOME Settings
  dconf.settings = with lib.hm.gvariant; {

    # Extension Settings
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = map (extension: extension.extensionUuid) home.packages;
      disabled-extensions = [ ];
    };


    # Mouse Settings
    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "flat";
      speed = -0.58;
    };
    # "org/gnome/desktop/wm/preferences/resize-with-right-button" = mkValue true;

    # "org/gnome/desktop/session/idle-delay" = mkUint32 900;

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

    # Folders
    "org/gnome/desktop/app-folders/folders/6e51d72d-eb2a-4f45-bc62-117f9eee3b94" = {
      name = "KDE";
      apps = [
        "org.kde.dolphin.desktop"
        "org.kde.kate.desktop"
        "org.kde.konsole.desktop"
        "org.kde.ark.desktop"
        "org.kde.klipper.desktop"
        "cups.desktop"
        "kdesystemsettings.desktop"
        "org.kde.kwalletmanager5.desktop"
        "org.kde.kwrite.desktop"
        "org.kde.spectacle.desktop"
        "org.kde.plasma-systemmonitor.desktop"
        "org.kde.kdeconnect.nonplasma.desktop"
        "org.kde.kdeconnect.app.desktop"
        "org.kde.kdeconnect-settings.desktop"
        "org.kde.kdeconnect.sms.desktop"
        "org.kde.kdeconnect_open.desktop"
      ];
    };
  };
}
