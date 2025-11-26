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
  # hardware.framework.enableKmod = true; # Allow userspace access to LEDs and battery charge limit
  services.hardware.bolt.enable = true;

  # powerprofilesctl configure-action amdgpu_dpm --enable
  boot.kernelParams = [
    "amdgpu.abmlevel=0" # Force off because it looks ugly
    "rcu_nocbs=all"
    "rcutree.enable_rcu_lazy=1"
    "pcie_aspm=force" # maybe?
    # "mem_sleep_default=deep" # break sleep behavior
    "pcie_aspm.policy=powersupersave"
    "nvme_core.default_ps_max_latency_us=5500"
  ];
  # systemd.sleep.extraConfig = "HibernateDelaySec=1h";
  services.logind.settings = {
    Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchDocked = "ignore";
      HandlePowerKey = "suspend";
    };
  };

  boot.extraModprobeConfig = ''
    # Disables ASPM for the mt7921e driver to prevent instability
    options mt7921e disable_aspm=1
  '';

  # Switch Power Profiles based on if plugged in or not
  # battery - ENV{POWER_SUPPLY_ONLINE}=="0"
  # AC - ENV{POWER_SUPPLY_ONLINE}=="1"
  services.udev.extraRules = lib.concatStringsSep "\n" [
    ''SUBSYSTEM=="power_supply",ENV{POWER_SUPPLY_ONLINE}=="1",RUN+="${lib.getExe pkgs.power-profiles-daemon} set balanced"''
    ''SUBSYSTEM=="power_supply",ENV{POWER_SUPPLY_ONLINE}=="0",RUN+="${lib.getExe pkgs.power-profiles-daemon} set power-saver"''
    # Allow waking from USB keyboards
    ''ACTION=="add", SUBSYSTEM=="usb", DRIVER=="usb", ATTR{power/wakeup}="enabled"''

    # Disable wake-on-lan for all PCIe devices
    ''ACTION=="add", SUBSYSTEM=="pci", DRIVER=="pcieport", ATTR{power/wakeup}="disabled"''
  ];
  #  SUBSYSTEM=="power_supply",ATTR{status}=="Discharging",ATTR{capacity_level}=="Low",RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver"

  # Auto-calibrate with powertop
  # powerManagement.powertop.enable = true;

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
    # Performance Tweaks courtesy of https://gitlab.com/cscs/maxperfwiz
    # These values are for navis only, please consult the script if copying these tweaks
    kernel.sysctl = {
      # The swappiness sysctl parameter represents the kernel's preference (or avoidance) of swap space.
      # Swappiness can have a value between 0 and 100, the default value is 60.
      # A low value causes the kernel to avoid swapping, a higher value causes the kernel to try to use swap space.
      # Using a low value on sufficient memory is known to improve responsiveness on many systems.
      "vm.swappiness" = 10;

      # VFS cache value controls the tendency of the kernel to reclaim the memory which is used for caching of directory and inode objects.
      # Lowering it from the default value of 100 makes the kernel less inclined to reclaim VFS cache.
      # Warning: do not set it to 0, this may produce out-of-memory conditions.
      "vm.vfs_cache_pressure" = 75;

      # Disabling watchdog will speed up your boot and shutdown, because one less module is loaded.
      # Additionally disabling watchdog timers increases performance and lowers power consumption.
      "kernel.nmi_watchdog" = 0;

      # vm.dirty_ratio determines, as a percentage of total available memory that contains free pages and reclaimable pages,
      # the number of pages at which a process which is generating disk writes will itself start writing out dirty data.
      # Note the optimum percentage may change depending on amount of available memory.
      # Values resulting in 100MB-600MB are ideal.
      "vm.dirty_bytes" = 419430400; # This should only be applied if RAM >= 16gb
      "vm.dirty_ratio" = 1;

      # vm.dirty_background_ratio determines, as a percentage of total available memory that contains free pages and reclaimable pages,
      # the number of pages at which the background kernel flusher threads will start writing out dirty data.
      # Note the optimum percentage may change depending on amount of available memory.
      # Values resulting in 50MB-400MB are ideal.
      "vm.dirty_background_bytes" = 209715200;
      "vm.dirty_background_ratio" = 1;

      # Dirty expire centisecs tunable is used to define when dirty data is old enough to be eligible for writeout by the kernel flusher threads,
      # expressed in 100'ths of a second. Data which has been dirty in-memory for longer than this interval will be written out next time a flusher thread wakes up.
      "vm.dirty_expire_centisecs" = 3000; # Should be 500 for HDD's

      # The kernel flusher threads will periodically wake up and write 'old' data out to disk.  This tunable expresses the interval between those wakeups, in 100'ths of a second.
      "vm.dirty_writeback_centisecs" = 1500; #should be 250 for HDD's

      # Increase vm.min_free_kbytes to improve desktop responsiveness and reduce long pauses due to swapping to disk.
      # One should increase this to (installed_mem / num_of_cores) * (0.05).
      "vm.min_free_kbytes" = 230487;
    };
  };
}
