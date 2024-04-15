{pkgs, ...}: {
  programs.dconf.enable = true; # Needed for many GTK apps (like GDM)
  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    # Terminal Commands
    vim
    git
    dig
    htop
    btop
    # coreutils-full
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
  ];
}
