{inputs, ...}: {
  # From the wonderful https://github.com/xddxdd/nix-cachyos-kernel
  # NixOS
  flake-file.inputs = {
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    # Do not override its nixpkgs input, otherwise there can be mismatch between patches and kernel version
  };

  flake.modules.nixos.system = {
    pkgs,
    lib,
    ...
  }: {
    nix.settings.substituters = ["https://attic.xuyh0120.win/lantian"];
    nix.settings.trusted-public-keys = ["lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="];
    nixpkgs.overlays = [
      # Use nixpkgs from your environment, nixpkgs.config will apply.
      # Has small chance of kernel modules not being compatible with kernel version.
      # inputs.nix-cachyos-kernel.overlays.default

      # Alternatively, use the exact nixpkgs revison as defined in this repo.
      # Guarantees you have binary cache, but initializes another nixpkgs instance.
      inputs.nix-cachyos-kernel.overlays.pinned

      # Only use one of the two overlays!
    ];
    # Firmware / Kernel
    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest; # pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3;
    powerManagement.cpuFreqGovernor = "schedutil";
    hardware.enableAllFirmware = true;
  };
}
