{
  pkgs,
  outputs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
    ./razer.nix
    ./networking.nix
    ../shared
    ../shared/desktop-enviroments/kde.nix

    # Hardware
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
  ];

  # System
  networking.hostName = "sirius";
  services.tailscale.enable = true;
  nixpkgs.overlays = [outputs.overlays.additions];
  # Gaming - Should be moved to home
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };
  environment.systemPackages = with pkgs; [
    mangohud # FPS Overlay
    # wisenet-viewer
    blueberry
  ];

  environment.shellAliases = {
    nix-switch = "sudo nixos-rebuild switch --flake ${outputs.flake-path}#sirius";
    home-switch = "home-manager switch --flake ${outputs.flake-path}#ben@sirius";
  };
}
