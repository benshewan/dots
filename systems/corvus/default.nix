{ inputs, flake-path, lib, ... }:
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
    systemd-boot.enable = lib.mkForce false;
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
    };
  };

  environment.shellAliases = {
    nix-switch = "sudo nixos-rebuild switch --flake ${flake-path}#corvus";
    reboot = "systemctl reboot";
  };
}
