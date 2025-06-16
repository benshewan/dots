{
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [inputs.nixos-hardware.nixosModules.framework-13-7040-amd];

  # Apply equalizer to speakers
  # Warning, must set real speakers to 100% first
  hardware.framework.laptop13.audioEnhancement.enable = false;
  hardware.framework.laptop13.audioEnhancement.hideRawDevice = false;
  hardware.framework.enableKmod = true; # Allow userspace access to LEDs and battery charge limit
  services.hardware.bolt.enable = true;

  # powerprofilesctl configure-action amdgpu_dpm --enable
  boot.kernelParams = [
    "amdgpu.abmlevel=0" # Force off because it looks ugly
    "rcu_nocbs=all"
    "rcutree.enable_rcu_lazy=1"
    # "pcie_aspm=force" # maybe?
  ];
  systemd.sleep.extraConfig = "HibernateDelaySec=1h";
  services.logind = {
    lidSwitch = "suspend-then-hibernate";
    lidSwitchDocked = "ignore";
    powerKey = "suspend-then-hibernate";
  };

  # Switch Power Profiles based on if plugged in or not
  # maybe
  # battery - ENV{POWER_SUPPLY_ONLINE}=="0"
  # AC - ENV{POWER_SUPPLY_ONLINE}=="1"
  services.udev.extraRules = lib.concatStringsSep "\n" [
    ''SUBSYSTEM=="power_supply",ENV{POWER_SUPPLY_ONLINE}=="1",RUN+="${lib.getExe pkgs.power-profiles-daemon} set balanced"''
    ''SUBSYSTEM=="power_supply",ENV{POWER_SUPPLY_ONLINE}=="0",RUN+="${lib.getExe pkgs.power-profiles-daemon} set power-saver"''

    # Testing with thunderbolt
    # ''ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{authorized}=="0", ATTR{authorized}="1"''
    # temp fix for bad lid behaviour, i.e. if system is suspended and the lid is closed it will wake back up
    # ''ACTION=="add", SUBSYSTEM=="serio", DRIVERS=="atkbd", ATTR{power/wakeup}="disabled"''
    # Allow waking from USB keyboards
    ''ACTION=="add", SUBSYSTEM=="usb", DRIVER=="usb", ATTR{power/wakeup}="enabled"''
  ];
  #  SUBSYSTEM=="power_supply",ATTR{status}=="Discharging",ATTR{capacity_level}=="Low",RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver"

  # Auto-calibrate with powertop
  powerManagement.powertop.enable = true;

  # AMD OpenGL/Vulkan stuff
  # hardware.graphics.extraPackages = [pkgs.rocm-opencl-icd pkgs.amdvlk];

  # Add support for temp, voltage, current, and power reading
  # boot.extraModulePackages = with config.boot.kernelPackages; [zenpower];

  # Firmware
  services.fwupd = {
    enable = true;
    extraRemotes = ["lvfs-testing"]; # Enable beta bios
  };

  # Fingerprint
  services.fprintd.enable = false;

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
  };
}
