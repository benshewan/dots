{ pkgs, ... }:
{

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
    exa
    clipboard-jh
    wget
    nil
    playerctl

    # nix stuff
    nix-prefetch-github
    nix-prefetch-git
    prefetch-npm-deps
    home-manager

    mpv # Media Player
    remmina # Remote desktop client
    kate # Text Editor

    # Development Runtimes 
    # Note: most things should be in project specfic flakes but I'm lazy, sue me.
    nodejs_20
    (python311.withPackages (ps: with ps; [
      openrazer
    ]))
    nodePackages.nodemon
  ];

  # fix for Via
  # services.udev.packages = with pkgs; [
  #   via
  # ];

  #Fonts
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" "RobotoMono" ]; })
    noto-fonts-cjk
    noto-fonts-emoji
  ];

  #Programs
  programs = {
    dconf.enable = true; # Needed for many GTK apps (like GDM)
    xwayland.enable = true; # Enable XWayland support
    fish.enable = true;
  };

  # Enable wayland support for chromium and most electron apps
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
