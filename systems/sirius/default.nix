{ pkgs, lib, flake_path, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ./nvidia.nix
      ../shared
      ../shared/desktop-enviroments/kde.nix
      ../shared/desktop-enviroments/gnome.nix
    ];

  # System
  networking.hostName = "sirius";

  # Default DE
  services.xserver.displayManager.defaultSession = "plasmawayland";


  # Force resolve conflict between GNOME and KDE
  programs.ssh.askPassword = lib.mkForce "${pkgs.ksshaskpass.out}/bin/ksshaskpass"; # Prefer KDE
  # programs.ssh.askPassword = lib.mkForce "${pkgs.gnome.seahorse.out}/libexec/seahorse/ssh-askpass"; # Prefer GNOME


  # Gaming
  programs.steam.enable = true;
  environment.systemPackages = with pkgs; [
    mangohud # FPS Overlay
  ];


  #Programs
  programs.fish.shellAbbrs = {
    nix-switch = "sudo nixos-rebuild switch --flake ${flake_path}#sirius";
  };
}
