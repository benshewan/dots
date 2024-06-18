{
  lib,
  pkgs,
  ...
}: {
  # Firmware / Kernel
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  hardware.enableAllFirmware = true;
}
