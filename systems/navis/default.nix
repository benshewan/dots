{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../shared
    ../shared/desktop-enviroments/gnome.nix
    inputs.nixos-hardware.nixosModules.framework
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

  # Power management
  services.power-profiles-daemon.enable = true;

  # Maybe needed for Thunderbolt - not sure yet
  # services.hardware.bolt.enable = true;

  # Need to set regulatory domain for AMD RZ616 wifi card
  # hardware.wirelessRegulatoryDatabase = true;
  #  boot.extraModprobeConfig = ''
  #   options cfg80211 ieee80211_regdom="CA"
  # '';

  # Audio Configuration https://github.com/ceiphr/ee-framework-presets
  environment.systemPackages = with pkgs; [
    easyeffects
  ];

  # potential fix if encoutering the "white flashes" bug in bios 3.02
  # boot.kernelParams = ["amdgpu.sg_display=0"];
}
