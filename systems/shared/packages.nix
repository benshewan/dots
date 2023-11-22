{
  pkgs,
  outputs,
  ...
}: {
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
  # services.udev.packages = with pkgs; [1
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
    fish.enable = true;
    adb.enable = true;
    nix-index-database.comma.enable = true; # Enable Comma, a tool to easily run any binary
    command-not-found.enable = false;
    # Allows nix shells to be auto run when entering the directory
    direnv = {
      package = pkgs.direnv;
      silent = false;
      loadInNixShell = true;
      direnvrcExtra = "";
      nix-direnv = {
        enable = true;
        package = pkgs.nix-direnv;
      };
    };
  };

  users.users.${outputs.username}.extraGroups = ["adbusers"];

  # Enable wayland support for chromium and most electron apps
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
