{ pkgs, flake-path, inputs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ./nvidia.nix
      ../shared
      # ../shared/desktop-enviroments/kde.nix
      # ../shared/desktop-enviroments/gnome.nix
      ../shared/desktop-enviroments/hyprland.nix

      # Hardware
      inputs.nixos-hardware.nixosModules.common-pc
      inputs.nixos-hardware.nixosModules.common-pc-ssd
      inputs.nixos-hardware.nixosModules.common-cpu-amd
      inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
    ];

  # System
  networking.hostName = "sirius";


  # Gaming - Should be moved to home
  programs.steam.enable = true;
  environment.systemPackages = with pkgs; [
    mangohud # FPS Overlay
  ];


  environment.shellAliases = {
    nix-switch = "sudo nixos-rebuild switch --flake ${flake-path}#sirius";
    reboot = "systemctl reboot";
  };
}
