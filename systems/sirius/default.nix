{ pkgs, flake_path, ... }:
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
  services.xserver.desktopManager.defaultSession = "plasmawayland";


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
