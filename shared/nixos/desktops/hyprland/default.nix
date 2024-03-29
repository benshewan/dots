{
  pkgs,
  inputs,
  config,
  outputs,
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
