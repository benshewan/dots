{
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [inputs.nixos-hardware.nixosModules.framework-13-7040-amd];

  # Additional power savings
  powerManagement.powertop.enable = true;

  # Switch Power Profiles based on if plugged in or not
  # maybe
  # battery - ENV{POWER_SUPPLY_ONLINE}=="0"
  # AC - ENV{POWER_SUPPLY_ONLINE}=="1"
  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply",ENV{POWER_SUPPLY_ONLINE}=="1",RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance"
    SUBSYSTEM=="power_supply",ENV{POWER_SUPPLY_ONLINE}=="0",RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver"
  '';
  #  SUBSYSTEM=="power_supply",ATTR{status}=="Discharging",ATTR{capacity_level}=="Low",RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver"

  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
    battery = {
      governor = "powersave";
      turbo = "never";
    };
    charger = {
      governor = "performance";
      turbo = "auto";
    };
  };

  # AMD OpenGL/Vulkan stuff
  # hardware.opengl.extraPackages = [pkgs.rocm-opencl-icd pkgs.amdvlk];

  boot.kernelParams = [
    # Potential fix for video stuttering
    # "amd_iommu=off"
    # reported to help with flashing display issues
    "amdgpu.sg_display=0"
  ];

  # Add support for temp, voltage, current, and power reading
  # boot.extraModulePackages = with config.boot.kernelPackages; [zenpower];

  # Auto Brightness
  location.provider = "geoclue2";
  services.clight = {
    enable = false;
    settings = {
      # dimmer.disabled = false;
    };
  };

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
}
