{
  pkgs,
  inputs,
  config,
  ...
}: {
  # Binary cache for hyprland nightly
  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };

  services.xserver.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    enableHidpi = true;
    theme = "chili";
  };

  # programs.regreet = {
  #   enable = true;
  #   cageArgs = ["-s" "-m" "last"];
  #   settings = {
  #     background.path = config.stylix.image;
  #     background.fit = "Fill";
  #     GTK.cursor_theme_name = config.stylix.cursor.name;
  #     GTK.theme_name = "Catppuccin-Mocha-Compact-Blue-Dark";
  #     GTK.font_name = "${config.stylix.fonts.sansSerif.name} ${toString config.stylix.fonts.sizes.desktop}";
  #     GTK.application_prefer_dark_theme =
  #       if config.stylix.polarity == "dark"
  #       then true
  #       else false;
  #   };
  # };

  # Add support for swaylock
  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };

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
  hardware.brillo.enable = true; # Add support for controlling brightness

  # Additional Services
  programs.partition-manager.enable = true;

  # Basic programs
  environment.systemPackages = with pkgs; [
    (sddm-chili-theme.override {
      themeConfig = {
        background = config.stylix.image;
        PasswordFieldOutlined = true;
      };
    })
    gnome.adwaita-icon-theme
  ];

  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };

  # KDE Connect plus some magic to get chromium browser integration working
  programs.kdeconnect.enable = true;
  environment.etc."chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json".source = "${pkgs.plasma-browser-integration}/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json";
}
