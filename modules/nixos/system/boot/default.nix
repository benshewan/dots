{lib, ...}: {
  # Boot Configuration
  boot = {
    # Plymouth
    kernelParams = ["quiet" "splash" "hib_compression=lz4"];
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
}
