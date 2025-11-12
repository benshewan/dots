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
    programs.uwsm.enable = true;
    programs.hyprland = {
      enable = true;
      # package = pkgs.hyprland;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland; # Unstable
      withUWSM = true;
    };

    night-sky.desktops.hyprland.greetd = lib.mkDefault true;
    services.xserver.displayManager.lightdm.enable = lib.mkDefault false;

    # services.displayManager.ly = {
    #   enable = true;
    #   settings = let
    #     inherit (config.lib.stylix) colors;
    #   in {
    #     waylandsessions = "${config.programs.hyprland.package}/share/wayland-sessions";
    #     asterisk = "0x2022";
    #     clear_password = false;
    #     load = true;
    #     save = true;

    #     bigclock = "en";
    #     clock = "%c";

    #     animation = "colormix";
    #     bg = "0x${colors.base0D}";
    #     border_fg = "0x${colors.base05}";

    #     # Color mixing animation first color id
    #     colormix_col1 = "0x00FF0000";

    #     # Color mixing animation second color id
    #     colormix_col2 = "0x000000FF";

    #     # Color mixing animation third color id
    #     colormix_col3 = "0x20000000";

    #     # Error background color id
    #     error_bg = "0x00000000";

    #     # Error foreground color id
    #     # Default is red and bold
    #     error_fg = "0x01FF0000";

    #     # Foreground color id
    #     fg = "0x00FFFFFF";

    #     # Main box horizontal margin
    #     # margin_box_h = 2

    #     # Main box vertical margin
    #     # margin_box_v = 1

    #     brightness_down_cmd = "${lib.getExe pkgs.brightnessctl} -e s 5%-";
    #     brightness_down_key = "XF86MonBrightnessDown";

    #     brightness_up_cmd = "${lib.getExe pkgs.brightnessctl} -e s 5%";
    #     brightness_up_key = "XF86MonBrightnessUp";
    #   };
    # };

    # Change how the power button works
    # services.logind.extraConfig = ''
    #   # don't shutdown when power button is short-pressed
    #   HandlePowerKey=suspend
    #   # Lock laptop instead of sleeping
    #   HandleLidSwitch=suspend
    # '';

    # Required Services
    services.gnome.gnome-keyring.enable = true; # Store secrets securely (Wifi passwords,git tokens, etc...)
    programs.seahorse.enable = true; # Manage Keys with a GUI
    services.blueman.enable = true; # GTK Bluetooth manager

    services.udisks2.enable = true; # Auto mount removable drives on connect
    # services.udisks2.settings = {
    #   "drive.conf".ATA.WriteCacheEnabled = false;
    # };

    programs.waybar.enable = true;

    # Additional Services
    programs.partition-manager.enable = true;

    # Basic programs
    environment.systemPackages = with pkgs; [
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
