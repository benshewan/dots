{ pkgs, flake_path, ... }:
{
  # List packages installed in system profile
  environment = {
    systemPackages = with pkgs; [
      # Terminal Commands
      vim
      git
      dig
      toybox
      neofetch
      bat
      exa
      clipboard-jh
      wget
      nix-prefetch-github
      nix-prefetch-git
      prefetch-npm-deps

      # Razer Specific Stuff
      # razergenie
      # (python311.withPackages (ps: with ps; [
      #   openrazer # Break into seprate flake for battery charge management
      #   # pygobject3
      #   # pyqt5
      #   # ruamel-yaml # Can't find libs in build but can in develop
      #   # pyinotify
      #   # pyqtwebengine
      # ]))
      mpv # Media Player
      lightly-qt # KDE Application Theme
      virt-manager # Virtual Machine Manager
      libsForQt5.kate # Text Editor

      # Development Runtimes 
      # Note: most things should be in project specfic flakes but I'm lazy, sue me.
      nodejs_20
      nodePackages.nodemon
    ];
  };

  #Fonts
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    noto-fonts-cjk
    noto-fonts-emoji
  ];



  #Programs
  programs = {
    dconf.enable = true; # Needed for many GTK apps (like GDM)
    xwayland.enable = true; # Enable XWayland support
    fish.enable = true;
  };
  #  KDE Connect plus some magic to get browser integration working
  # Note that native messaging hosts dont work with firefox-bin
  programs.kdeconnect.enable = true;
  environment.etc."chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json".source = "${pkgs.plasma-browser-integration}/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json";

  # Program Fixes

  # Enable wayland support for chromium and most electron apps
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

}
