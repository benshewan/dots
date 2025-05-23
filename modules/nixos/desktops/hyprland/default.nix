{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: let
  cfg = config.night-sky.desktops.hyprland;
in {
  options.night-sky.desktops.hyprland = {
    enable = lib.mkEnableOption "hyprland";
  };

  config = lib.mkIf cfg.enable {
    # Binary cache for hyprland nightly
    # nix.settings = {
    #   substituters = ["https://hyprland.cachix.org"];
    #   trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    # };
    programs.uwsm.enable = true;
    programs.hyprland = {
      enable = true;
      package = pkgs.hyprland;
      # package = inputs.hyprland.packages.${pkgs.system}.hyprland; # Unstable
      withUWSM = true;
    };

    night-sky.desktops.hyprland.gdm = lib.mkDefault true;
    services.xserver.displayManager.lightdm.enable = lib.mkDefault false;

    # ------------------------------ Testing ------------------------------

    # services.displayManager.sddm = {
    #   enable = true;
    #   wayland.enable = true;
    #   theme = "chili";
    # };

    # Change how the power button works
    services.logind.extraConfig = ''
      # don't shutdown when power button is short-pressed
      HandlePowerKey=suspend
      # Lock laptop instead of sleeping
      # HandleLidSwitch=lock
    '';

    # Required Services
    services.gnome.gnome-keyring.enable = true; # Store secrets securely (Wifi passwords,git tokens, etc...)
    programs.seahorse.enable = true; # Manage Keys with a GUI
    services.blueman.enable = true; # GTK Bluetooth manager

    services.udisks2.enable = true; # Auto mount removable drives on connect
    services.udisks2.settings = {
    };
    programs.waybar.enable = true;

    # Additional Services
    programs.partition-manager.enable = true;

    # Basic programs
    environment.systemPackages = with pkgs; [
      # (sddm-chili-theme.override {
      #   themeConfig = {
      #     background = config.stylix.image;
      #     PasswordFieldOutlined = true;
      #   };
      # })
      adwaita-icon-theme
    ];

    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
    };

    # KDE Connect plus some magic to get chromium browser integration working
    programs.kdeconnect.enable = true;
    # Handled by programs.chromium.enablePlasmaBrowserIntegration now
    # environment.etc."chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json".source = "${pkgs.kdePackages.plasma-browser-integration}/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json";
  };
}
