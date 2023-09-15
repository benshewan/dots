{ inputs, lib, outputs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ../shared
      ../shared/desktop-enviroments/gnome.nix
      inputs.nixos-hardware.nixosModules.dell-xps-15-9560-intel
    ];

  # System
  networking.hostName = "corvus";

  # Temp until full reformat
  boot.loader = {
    efi.efiSysMountPoint = "/boot/efi";
    systemd-boot.enable = lib.mkForce false;
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
    };
  };

  environment.shellAliases = {
    nix-switch = "sudo nixos-rebuild switch --flake ${outputs.flake-path}#corvus";
    home-switch = "home-manager switch --flake ${outputs.flake-path}#ben@corvus";
  };
}
