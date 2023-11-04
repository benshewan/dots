{
  pkgs,
  config,
  lib,
  outputs,
  ...
}: {
  programs.hyprland.enable = true;

  # Auto Login
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = lib.getExe pkgs.hyprland;
        user = outputs.username;
      };
      default_session = initial_session;
    };
  };

  # Tryed to use hyprland for greetd - didn't really work
  # services.greetd = {
  #   enable = true;
  #   settings = rec {
  #     initial_session = {
  #       command = let
  #         greetdHyprlandConfig = pkgs.writeText "hyprland.conf" ''
  #           exec-once = regreet; hyprctl dispatch exit
  #         '';
  #       in "${lib.getExe pkgs.hyprland} --config ${greetdHyprlandConfig}";
  #     };
  #     default_session = initial_session;
  #   };
  # };
  # Greetd seems to be broken right now
  programs.regreet = {
    enable = true;
    cageArgs = ["-m last"];
    settings = {
      background.path = ../../../wallpapers/nix-black-4k.png;
    };
  };

  # Add support for swaylock
  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };

  services.logind.extraConfig = ''
    # don't shutdown when power button is short-pressed
    HandlePowerKey=suspend
    # Lock laptop instead of sleeping
    # HandleLidSwitch=lock
  '';

  services.gnome.gnome-keyring.enable = true; # Store secrets securely (Wifi passwords,git tokens, etc...)
  programs.seahorse.enable = true; # Manage Keys with a GUI

  services.udisks2.enable = true; # Auto mount removable drives on connect
  hardware.brillo.enable = true; # Add support for controlling brightness

  environment.systemPackages =
    (with pkgs; [
      gparted
      # Dolphin and assorted dependencies for it
      taglib
      ffmpegthumbnailer
    ])
    ++ (with pkgs.libsForQt5; [
      dolphin
      ark
      baloo
      dolphin-plugins
      kdegraphics-thumbnailers
      kio
      kio-extras
      breeze-icons
    ]);

  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };

  # KDE Connect plus some magic to get chromium browser integration working
  programs.kdeconnect.enable = true;
  environment.etc."chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json".source = "${pkgs.plasma-browser-integration}/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json";
}
