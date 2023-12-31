{
  pkgs,
  outputs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
    ./razer.nix
    ./networking.nix
    ../shared
    ../shared/desktop-enviroments/hyprland.nix

    # Hardware
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
  ];

  # System
  networking.hostName = "sirius";
  services.tailscale.enable = true;
  # Gaming - Should be moved to home
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };
  environment.systemPackages = with pkgs; [
    mangohud # FPS Overlay
    prismlauncher # Minecraft launcher
    # wisenet-viewer
    blueberry
  ];
}
