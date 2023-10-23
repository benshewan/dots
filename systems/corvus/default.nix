{
  inputs,
  lib,
  outputs,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../shared
    ../shared/desktop-enviroments/gnome.nix
    inputs.nixos-hardware.nixosModules.dell-xps-15-9560-intel
  ];

  # System
  networking.hostName = "corvus";

  # Remote management of Lepus
  services.tailscale.enable = true;
  environment.systemPackages = with pkgs; [
    moonlight-qt
  ];

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
}
