# Kernel/module support for the QEMU guest. Filesystems are declared by
# machines/caelum/disko.nix (disko), not here.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = ["ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
