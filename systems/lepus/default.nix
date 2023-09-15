{ inputs, outputs, ... }:
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
    nix-switch = "sudo nixos-rebuild switch --flake ${outputs.flake-path}#lepus";
    home-switch = "home-manager switch --flake ${outputs.flake-path}#ben@lepus";
  };
}
