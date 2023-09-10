{ pkgs, lib, config, ... }:
rec {
  # GNOME Extensions
  home.packages = with pkgs.gnomeExtensions; [
    user-themes
    vitals
    dash-to-dock
    blur-my-shell
    gsconnect
    appindicator
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
      speed = -0.58;
    };
    "org/gnome/desktop/wm/preferences" = {
      resize-with-right-button = true;
    };

    # Time before screen goes dark (seconds)
    "org/gnome/desktop/session" = {
      idle-delay = mkUint32 900;
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
  };
}
