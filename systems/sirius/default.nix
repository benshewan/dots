{ pkgs, flake_path, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ./nvidia.nix
      ../shared
      ../shared/desktop-enviroments/hyprland.nix
      # ../shared/desktop-enviroments/gnome.nix
    ];

  # System
  networking.hostName = "sirius";


  # Gaming
  programs.steam.enable = true;
  environment.systemPackages = with pkgs; [
    mangohud # FPS Overlay
  ];


  environment.shellAliases = {
    nix-switch = "sudo nixos-rebuild switch --flake ${flake_path}#sirius";
    reboot = "systemctl reboot";
  };
}
