{
  lib,
  inputs,
  ...
}: {
  imports = [inputs.lanzaboote.nixosModules.lanzaboote];

  # Secure Boot Configuration
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };
  # boot.loader.systemd-boot.enable = lib.mkForce false;
  # Boot Configuration
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
        # For lanzaboote to work this needs to be false
        enable = lib.mkForce false;
        # enable = true;
        editor = false;
        consoleMode = "auto";
        configurationLimit = 25;
      };
    };
  };
}
