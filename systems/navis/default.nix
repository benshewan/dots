{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../shared
    ../shared/desktop-enviroments/kde.nix
    # inputs.nixos-hardware.nixosModules.framework
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
  ];

  boot.kernelParams = [
    # For Power consumption
    # https://kvark.github.io/linux/framework/2021/10/17/framework-nixos.html
    # "mem_sleep_default=deep"
    "acpi_osi=\"!Windows 2020\""
  ];

  # System
  networking.hostName = "navis";

  # Remote management of Navis
  services.tailscale.enable = true;

  # Power management
  # services.power-profiles-daemon.enable = true;
  services.auto-cpufreq = {
    enable = true;
    settings = {
      charger = {
        governor = "preformance";
        scaling_min_freq = 3300000; # 800MHz
        scaling_max_freq = 5100000; # 1GHz
        turbo = "auto";
      };
      battery = {
        governor = "powersave";
        scaling_min_freq = 800000; # 800MHz
        scaling_max_freq = 3300000; # 1GHz
        turbo = "auto";
      };
    };
  };
  # Maybe needed for Thunderbolt - not sure yet
  services.hardware.bolt.enable = true;

  # Fingerprint
  services.fprintd.enable = true;

  # Firmware
  services.fwupd = {
    enable = true;
    extraRemotes = ["lvfs-testing"]; # Enable beta bios
  };

  # Need to set regulatory domain for AMD RZ616 wifi card
  hardware.wirelessRegulatoryDatabase = true;
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom="CA"
  '';

  environment.systemPackages = with pkgs; [
    # Audio Configuration https://github.com/ceiphr/ee-framework-presets
    easyeffects

    # View Power Draw
    powertop
  ];
}
