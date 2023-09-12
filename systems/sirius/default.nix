{ pkgs, flake_path, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ./nvidia.nix
      ../shared
      # ../shared/desktop-enviroments/kde.nix
      # ../shared/desktop-enviroments/gnome.nix
      ../shared/desktop-enviroments/hyprland.nix
    ];

  # System
  networking.hostName = "sirius";


  # Gaming - Should be moved to home
  programs.steam.enable = true;
  environment.systemPackages = with pkgs; [
    mangohud # FPS Overlay
  ];


  environment.shellAliases = {
    nix-switch = "sudo nixos-rebuild switch --flake ${flake_path}#sirius";
    reboot = "systemctl reboot";
  };
}
