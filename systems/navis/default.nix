{inputs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ../shared
    ../shared/desktop-enviroments/gnome.nix
    inputs.nixos-hardware.nixosModules.framework
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
  ];

  # System
  networking.hostName = "navis";

  # Remote management of Navis
  services.tailscale.enable = true;
}
