{config, ...}: {
  # NixOS
  flake.modules.nixos.system = {
    pkgs,
    lib,
    ...
  }: {
    time.timeZone = lib.mkDefault config.flake.meta.hosts.timezone;
    # Disable systemd TPM2 setup services - they wait for measured UKI which we don't use
    # This prevents a 60+ second timeout during boot
    systemd.services = {
      systemd-tpm2-setup-early.enable = false;
      systemd-tpm2-setup.enable = false;

      # Disable NetworkManager-wait-online - most systems don't need to block boot for network
      # This saves ~5 seconds during boot
      NetworkManager-wait-online.enable = false;
    };

    # Enable ~/.local/bin in PATH for user-installed binaries (e.g. uv tools)
    environment.localBinInPath = true;

    # Firmware / Kernel
    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    powerManagement.cpuFreqGovernor = "schedutil";
    hardware.enableAllFirmware = true;

    # Some basic nice aliases
    environment.shellAliases = {
      reboot = "systemctl reboot";
      poweroff = "systemctl poweroff";
    };

    boot = {
      # Plymouth
      kernelParams = ["quiet" "splash"];
      initrd.systemd.enable = true;
      consoleLogLevel = 0;
      initrd.verbose = false;
      plymouth.enable = true;

      # Systemd-boot
      loader = {
        timeout = lib.mkDefault 5;
        efi.canTouchEfiVariables = true;
        systemd-boot = {
          enable = true;
          editor = false;
          consoleMode = "auto";
          configurationLimit = 25;
        };
      };
    };
  };

  # Darwin
  flake.modules.darwin.system = {
  };

  # Home Manager
  flake.modules.homeManager.system = {
    home.preferXdgDirectories = true;
  };
}
