{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../shared
    ../shared/desktop-enviroments/hyprland.nix
    # ./tlp.nix
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
  ];

  # Newer kernel is better for amdgpu driver updates
  # Requires at least 5.16 for working wi-fi and bluetooth (RZ616, kmod mt7922):
  # https://wireless.wiki.kernel.org/en/users/drivers/mediatek
  boot.kernelPackages = lib.mkIf (lib.versionOlder pkgs.linux.version "6.1") (lib.mkDefault pkgs.linuxPackages_latest);

  # AMD has better battery life with PPD over TLP:
  # https://community.frame.work/t/responded-amd-7040-sleep-states/38101/13
  services.power-profiles-daemon.enable = lib.mkDefault true;

  # Fix TRRS headphones missing a mic
  # https://community.frame.work/t/headset-microphone-on-linux/12387/3
  boot.extraModprobeConfig = ''
    options snd-hda-intel model=dell-headset-multi

    options cfg80211 ieee80211_regdom="CA"
  '';

  # Additional power savings
  powerManagement.powertop.enable = true;
  services.auto-cpufreq.enable = true;

  # For fingerprint support
  services.fprintd.enable = lib.mkDefault true;
  # security.pam.system-auth = {
  # };

  # AMD OpenGL/Vulkan stuff
  hardware.opengl.extraPackages = [pkgs.rocm-opencl-icd pkgs.amdvlk];

  # Custom udev rules
  services.udev.extraRules = ''
    # Ethernet expansion card support
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="8156", ATTR{power/autosuspend}="20"
  '';

  # Needed for desktop environments to detect/manage display brightness
  hardware.sensor.iio.enable = lib.mkDefault true;

  boot.kernelParams = [
    # Potential fix for video stuttering
    "amd_iommu=off"
    # reported to help with flashing display issues
    # "amdgpu.sg_display=0"
  ];

  # Add support for temp, voltage, current, and power reading
  boot.extraModulePackages = with config.boot.kernelPackages; [zenpower];

  # System
  networking.hostName = "navis";

  # Remote management of Navis
  services.tailscale.enable = true;

  # Auto Brightness
  location.provider = "geoclue2";
  services.clight = {
    enable = false;
    settings = {
      # dimmer.disabled = false;
    };
  };

  # Maybe needed for Thunderbolt - not sure yet
  # services.hardware.bolt.enable = true;

  # Firmware
  services.fwupd = {
    enable = true;
    extraRemotes = ["lvfs-testing"]; # Enable beta bios
  };

  # Need to set regulatory domain for AMD RZ616 wifi card
  hardware.wirelessRegulatoryDatabase = true;
  # boot.extraModprobeConfig = ''
  #   options cfg80211 ieee80211_regdom="CA"
  # '';

  environment.systemPackages = with pkgs; [
    # Audio Configuration https://github.com/ceiphr/ee-framework-presets
    easyeffects
    powertop
    nm-tray
  ];
}
