{
  pkgs,
  inputs,
  ...
}: {
  imports = [inputs.nixos-hardware.nixosModules.framework-13-7040-amd];

  # Apply equalizer to speakers
  # Warning, must set real speakers to 100% first
  hardware.framework.laptop13.audioEnhancement.enable = false;
  hardware.framework.laptop13.audioEnhancement.hideRawDevice = false;
  services.hardware.bolt.enable = true;

  # Change hiberate settings for better battery
  # boot.resumeDevice = "/dev/nvme0n1p3";
  boot.kernelParams = [
    "amdgpu.abmlevel=0" # Force off because it looks ugly
  ];
  # systemd.sleep.extraConfig = "HibernateDelaySec=2h";
  services.logind = {
    lidSwitch = "suspend-then-hibernate";
    extraConfig = ''
      HandlePowerKey=suspend-then-hibernate
      IdleAction=suspend-then-hibernate
      IdleActionSec=2m
    '';
  };

  # Switch Power Profiles based on if plugged in or not
  # maybe
  # battery - ENV{POWER_SUPPLY_ONLINE}=="0"
  # AC - ENV{POWER_SUPPLY_ONLINE}=="1"
  services.udev.extraRules =
    ''
      ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{authorized}=="0", ATTR{authorized}="1"
      SUBSYSTEM=="power_supply",ENV{POWER_SUPPLY_ONLINE}=="1",RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced "
      SUBSYSTEM=="power_supply",ENV{POWER_SUPPLY_ONLINE}=="0",RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver"
    ''
    # temp fix for bad lid behaviour, i.e. if system is suspended and the lid is closed it will wake back up
    + ''ACTION=="add", SUBSYSTEM=="serio", DRIVERS=="atkbd", ATTR{power/wakeup}="disabled"''
    # Allow waking from USB keyboards
    + ''ACTION=="add", SUBSYSTEM=="usb", DRIVER=="usb", ATTR{power/wakeup}="enabled"'';
  #  SUBSYSTEM=="power_supply",ATTR{status}=="Discharging",ATTR{capacity_level}=="Low",RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver"

  services.auto-cpufreq.enable = false;
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
  # hardware.graphics.extraPackages = [pkgs.rocm-opencl-icd pkgs.amdvlk];

  # boot.kernelParams = [
  #   # Adaptive Backlight Management (0-4)
  #   "amdgpu.abmlevel=0" # Force off because it looks ugly
  # ];

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
