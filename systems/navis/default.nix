{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./hardware.nix
    ../shared
    ../shared/desktop-enviroments/hyprland.nix
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
  ];

  # System
  networking.hostName = "navis";

  # Remote management of Navis
  services.tailscale.enable = true;

  environment.systemPackages = with pkgs; [
    # Audio Configuration https://github.com/ceiphr/ee-framework-presets
    easyeffects
    powertop
    nm-tray
    stable.nodejs
  ];

  services.mongodb = {
    enable = true;
    package = pkgs.stable.mongodb;
  };
}
