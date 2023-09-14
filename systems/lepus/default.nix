{ inputs, flake-path, lib, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ../shared
      ../shared/desktop-enviroments/gnome.nix
      inputs.nixos-hardware.nixosModules.common-pc
      inputs.nixos-hardware.nixosModules.common-pc-ssd
      inputs.nixos-hardware.nixosModules.common-cpu-intel
    ];

  # System
  networking.hostName = "lepus";

  environment.shellAliases = {
    nix-switch = "sudo nixos-rebuild switch --flake ${flake-path}#lepus";
    reboot = "systemctl reboot";
  };
}
