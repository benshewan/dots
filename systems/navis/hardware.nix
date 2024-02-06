{
  pkgs,
  config,
  inputs,
  lib,
  ...
}: {
  imports = [inputs.nixos-hardware.nixosModules.framework-13-7040-amd];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.framework.amd-7040.preventWakeOnAC = true;

  services.keylightd.enable = false;
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
      IdleActionSec=30m
    '';
  };

  # Switch Power Profiles based on if plugged in or not
  # maybe
  # battery - ENV{POWER_SUPPLY_ONLINE}=="0"
  # AC - ENV{POWER_SUPPLY_ONLINE}=="1"
  services.udev.extraRules =
    ''
      SUBSYSTEM=="power_supply",ENV{POWER_SUPPLY_ONLINE}=="1",RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced"
      SUBSYSTEM=="power_supply",ENV{POWER_SUPPLY_ONLINE}=="0",RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver"
    ''
    # temp fix for bad lid behaviour, i.e. if system is suspended and the lid is closed it will wake back up
    + ''ACTION=="add", SUBSYSTEM=="serio", DRIVERS=="atkbd", ATTR{power/wakeup}="disabled"''
    # Allow waking from USB keyboards
    + ''ACTION=="add", SUBSYSTEM=="usb", DRIVER=="usb", ATTR{power/wakeup}="enabled"'';
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

  # Set timeout for bluetooth to save power
  hardware.bluetooth.input = {
    General = {
      IdleTimeout = 30;
    };
  };

  # AMD OpenGL/Vulkan stuff
  hardware.opengl.extraPackages = [pkgs.rocm-opencl-icd pkgs.amdvlk];

  boot.kernelParams = [
    # Potential fix for video stuttering
    # "amd_iommu=off"
    # reported to help with flashing display issues
    "amdgpu.sg_display=0"

    # Adaptive Backlight Management (1-4)
    # "amdgpu.abmlevel=3"
  ];

  # Add support for temp, voltage, current, and power reading
  # boot.extraModulePackages = with config.boot.kernelPackages; [zenpower];

  # Auto Brightness - taken from https://github.com/FedeDP/Clight/issues/253#issue-1358215844
  location.provider = "geoclue2";
  services.clight = {
    enable = true;

    ## Gamma temperature during day and night
    ## this nix option overrides gamma.temp
    temperature.day = 5500;
    temperature.night = 3700;

    settings = {
      verbose = false;
      resumedelay = 0;

      inhibit = {
        disabled = false;
        inhibit_docked = true;
        inhibit_pm = true;
        inhibit_bl = true;
      };

      backlight = {
        disabled = false;
        restore_on_exit = true;
        no_smooth_transition = false;
        trans_step = 0.05;
        trans_timeout = 30;
        trans_fixed = 0;
        ac_timeouts = [600 2700 300];
        batt_timeouts = [1200 5400 600];
        shutter_threshold = 0.00; # 0.10
        no_auto_calibration = false;
        pause_on_lid_closed = true;
        capture_on_lid_opened = true;
      };

      sensor = {
        ac_regression_points = [0.0 0.15 0.29 0.45 0.61 0.74 0.81 0.88 0.93 0.97 1.0];
        batt_regression_points = [0.0 0.15 0.23 0.36 0.52 0.59 0.65 0.71 0.75 0.78 0.80];
        devname = "";
        settings = "";
        captures = [5 5];
      };

      keyboard = {
        disabled = true;
        timeouts = [15 7];
        ac_regression_points = [1.0 0.97 0.93 0.88 0.81 0.74 0.61 0.45 0.29 0.15 0.0];
        batt_regression_points = [0.80 0.78 0.75 0.71 0.65 0.59 0.52 0.36 0.23 0.15 0.0];
      };

      gamma = {
        disabled = true;
        restore_on_exit = true;
        no_smooth_transition = false;
        trans_step = 50;
        trans_timeout = 300;
        long_transition = true;
        ambient_gamma = false;
      };

      # daytime = {
      #   sunrise = "6:30";
      #   sunset = "20:30";
      #   event_duration = 1800;
      #   sunrise_offset = 0;
      #   sunset_offset = 0;
      # };

      dimmer = rec {
        disabled = false;
        no_smooth_transition = [false false];
        trans_steps = [0.01 0.08];
        trans_timeouts = let
          # calculates a duration for each step between
          # full brightness and the dimmed percentage
          formula = duration: target: step: builtins.floor (duration / ((1 - target) / step));
        in [
          (formula 2000 dimmed_pct (builtins.elemAt trans_steps 0))
          (formula 250 dimmed_pct (builtins.elemAt trans_steps 1))
        ];
        trans_fixed = [0 0];
        timeouts = [30 15];
        dimmed_pct = 0.2;
      };

      dpms = {
        disabled = true;
        timeouts = [900 300];
      };

      screen = {
        disabled = true;
        contrib = 0.2;
        timeouts = [5 0];
      };
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

  # Fingerprint
  services.fprintd.enable = true;
  security.pam.services.login.fprintAuth = false;
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
  hardware.firmware = [
    (
      let
        betaVCNblob = builtins.fetchurl {
          url = "https://gitlab.freedesktop.org/mesa/mesa/uploads/f51d221a24d4ac354e2d1d901613b594/vcn_4_0_2.bin";
          sha256 = "sha256:0rg4sm6sivn6s356cnxgfqq5d7gg2f3ghwi3psc0w6i7pks3i3z8";
        };
      in
        pkgs.runCommandNoCC "betaVCNblob" {} ''
          mkdir -p $out/lib/firmware/amdgpu
          cp ${betaVCNblob} $out/lib/firmware/amdgpu/vcn_4_0_2.bin
        ''
    )
  ];

  # Patched PPD https://community.frame.work/t/tracking-ppd-v-tlp-for-amd-ryzen-7040/39423/137
  services.power-profiles-daemon.package = pkgs.power-profiles-daemon.overrideAttrs {
    src = inputs.power-profiles-daemon;
    version = inputs.power-profiles-daemon.rev;
  };
}
