{
  pkgs,
  inputs,
  ...
}: {
  imports = [inputs.nixos-hardware.nixosModules.framework-13-7040-amd];

  services.hardware.bolt.enable = true;
  # Additional power savings
  # Note: doesn't whtelist inputs devices, can be funky
  # powerManagement.powertop.enable = true;
  # config.systemd.services.powertop.serviceConfig.ExecStartPost = ''${pkgs.bash} -c ${pkgs.coreutils}/bin/echo on > $(grep -Rl "USB Receiver" /sys/bus/usb/devices/*/product | sed "s/product/power\\/control/") || true'';

  # Change hiberate settings for better battery
  boot.resumeDevice = "/dev/nvme0n1p3";
  systemd.sleep.extraConfig = "HibernateDelaySec=2h";
  services.logind = {
    lidSwitch = "suspend-then-hibernate";
    extraConfig = ''
      HandlePowerKey=suspend-then-hibernate
      IdleAction=suspend-then-hibernate
      IdleActionSec=2m
      HibernateDelaySec=30m
    '';
  };

  # Switch Power Profiles based on if plugged in or not
  # maybe
  # battery - ENV{POWER_SUPPLY_ONLINE}=="0"
  # AC - ENV{POWER_SUPPLY_ONLINE}=="1"
  services.udev.extraRules =
    ''
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
  hardware.graphics.extraPackages = [pkgs.rocm-opencl-icd pkgs.amdvlk];

  boot.kernelParams = [
    # Potential fix for video stuttering
    # "amd_iommu=off"
    # reported to help with flashing display issues
    # "amdgpu.sg_display=0"

    # Adaptive Backlight Management (0-4)
    "amdgpu.abmlevel=0" # Force off because it looks ugly
  ];

  # Add support for temp, voltage, current, and power reading
  # boot.extraModulePackages = with config.boot.kernelPackages; [zenpower];

  # Firmware
  services.fwupd = {
    enable = true;
    extraRemotes = ["lvfs-testing"]; # Enable beta bios
  };

  # Fingerprint
  services.fprintd.enable = false;
  # security.pam.services.login.fprintAuth = false;
  # similarly to how other distributions handle the fingerprinting login
  # security.pam.services.gdm-fingerprint = lib.mkIf (config.services.fprintd.enable) {
  #   text = ''
  #     auth       required                    pam_shells.so
  #     auth       requisite                   pam_nologin.so
  #     auth       requisite                   pam_faillock.so      preauth
  #     auth       required                    ${pkgs.fprintd}/lib/security/pam_fprintd.so
  #     auth       optional                    pam_permit.so
  #     auth       required                    pam_env.so
  #     auth       [success=ok default=1]      ${pkgs.gnome.gdm}/lib/security/pam_gdm.so
  #     auth       optional                    ${pkgs.gnome.gnome-keyring}/lib/security/pam_gnome_keyring.so

  #     account    include                     login

  #     password   required                    pam_deny.so

  #     session    include                     login
  #     session    optional                    ${pkgs.gnome.gnome-keyring}/lib/security/pam_gnome_keyring.so auto_start
  #   '';
  # };

  # beta firmware blob to fix VAAPi VP9 decoding glitches
  # (see https://gitlab.freedesktop.org/mesa/mesa/-/issues/8044#note_2195102 and
  # https://community.frame.work/t/active-upstream-amdgpu-issues-affecting-ryzen-7840u-igpu-780m/41053/8)
  # hardware.firmware = [
  #   (
  #     let
  #       betaVCNblob = builtins.fetchurl {
  #         url = "https://gitlab.freedesktop.org/mesa/mesa/uploads/f51d221a24d4ac354e2d1d901613b594/vcn_4_0_2.bin";
  #         sha256 = "sha256:0rg4sm6sivn6s356cnxgfqq5d7gg2f3ghwi3psc0w6i7pks3i3z8";
  #       };
  #     in
  #       pkgs.runCommandNoCC "betaVCNblob" {} ''
  #         mkdir -p $out/lib/firmware/amdgpu
  #         cp ${betaVCNblob} $out/lib/firmware/amdgpu/vcn_4_0_2.bin
  #       ''
  #   )
  # ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    # kernelPatches = [
    #   # https://community.frame.work/t/guide-fw13-ryzen-power-management/42988/68
    #   {
    #     patch = pkgs.fetchpatch2 {
    #       name = "amdgpu-vcn-1.diff";
    #       url = "https://git.kernel.org/pub/scm/linux/kernel/git/superm1/linux.git/rawdiff/?h=superm1/vcn-dpg-6.9&id=13b322789fae1d6a1fad2c09887fbd9c25ecddc4";
    #       hash = "sha256-Apf+jhlaLf9+AbLxJ1yWb2Ka5b3OfIV3gNIqnfnNwho=";
    #     };
    #   }
    #   {
    #     patch = pkgs.fetchpatch2 {
    #       name = "amdgpu-vcn-2.diff";
    #       url = "https://git.kernel.org/pub/scm/linux/kernel/git/superm1/linux.git/rawdiff/?h=superm1/vcn-dpg-6.9&id=c6b76db6ce46eab7d186b68b5ed4bea4d3800161";
    #       hash = "sha256-yZ9p/G/YMlreloF3Cq9dsshO1Oomj6+IVJkl/TH0/VE=";
    #     };
    #   }
    # ];
  };
}
