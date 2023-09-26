{pkgs, ...}: {
  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    # Terminal Commands
    vim
    git
    dig
    htop
    btop
    toybox
    neofetch
    bat
    clipboard-jh
    wget
    playerctl

    # nix stuff
    nix-prefetch-github
    nix-prefetch-git
    prefetch-npm-deps
    home-manager

    mpv # Media Player
    kate # Text Editor
  ];

  # fix for Via # Doesn't work - look into maybe
  # services.udev.packages = with pkgs; [
  #   via
  # ];

  #Fonts
  fonts.packages = with pkgs; [
    (nerdfonts.override {fonts = ["JetBrainsMono" "RobotoMono"];})
    noto-fonts-cjk
    noto-fonts-emoji
  ];

  #Programs
  programs = {
    dconf.enable = true; # Needed for many GTK apps (like GDM)
    xwayland.enable = true; # Enable XWayland support
    direnv.enable = true; # Allows nix shells to be auto run when entering the directory
    fish.enable = true;
  };

  # Enable wayland support for chromium and most electron apps
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
