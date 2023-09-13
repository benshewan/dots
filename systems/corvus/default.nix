{ pkgs, flake-path, lib, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ../shared
      ../shared/desktop-enviroments/gnome.nix
    ];

  # System
  networking.hostName = "corvus";

  # Temp until full reformat
  boot.loader = {
    systemd-boot.enable = lib.mkForce false;
    grub = {
      enable = true;
      version = 2;
      device = "nodev";
      efiSupport = true;
    };
  };

  environment.shellAliases = {
    nix-switch = "sudo nixos-rebuild switch --flake ${flake-path}#corvus";
    reboot = "systemctl reboot";
  };
}
