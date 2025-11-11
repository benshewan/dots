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
    sysz
    # coreutils-full
    neofetch
    bat
    wget
    playerctl
    busybox

    # nix stuff
    # snowfallorg.flake
    nix-prefetch-github
    nix-prefetch-git
    prefetch-npm-deps
    home-manager
  ];
}
