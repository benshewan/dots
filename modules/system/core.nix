{config, ...}: let
  # Flake-level metadata, captured here because the NixOS module below shadows
  # `config` with the module-system config.
  inherit (config.flake) meta;
in {
  # NixOS
  flake.modules.nixos.system = {
    pkgs,
    lib,
    config,
    ...
  }: {
    time.timeZone = lib.mkDefault meta.hosts.timezone;
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

    # Bound the journal: the default is 10% of the filesystem (up to 4 GiB).
    services.journald.settings.Journal.SystemMaxUse = "1G";

    # Firmware
    hardware.enableAllFirmware = true;

    # Enable support for apple apfs filesystem, note: doesn't seem to work with my cachy kernel
    # boot.supportedFilesystems.apfs = true;

    # Some basic nice aliases
    environment.shellAliases = {
      reboot = "systemctl reboot";
      poweroff = "systemctl poweroff";
    };

    boot = {
      # Silence the console behind the boot splash (splash param itself is
      # added by the plymouth module in modules/system/plymouth.nix).
      kernelParams = ["quiet"];
      consoleLogLevel = lib.mkDefault 0;

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
    xdg.enable = true;
    home.preferXdgDirectories = true;
    # Disable home-manager's generated manual pages. Building them runs nixpkgs'
    # make-options-doc, which produces an unreliable options.json derivation
    # (the "builtins.derivation named 'options.json'" warning).
    manual.manpages.enable = false;
  };
}
