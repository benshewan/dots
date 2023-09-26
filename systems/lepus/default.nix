{
  inputs,
  outputs,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ../shared
    ../shared/desktop-enviroments/gnome.nix
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.common-cpu-intel
  ];

  # System
  networking.hostName = "lepus";

  nixpkgs.overlays = [outputs.overlays.additions];
  # Remote Management
  services.tailscale.enable = true;
  services.mongodb.enable = true;
  environment.systemPackages = with pkgs; [
    trayscale
    inkscape
    wisenet-viewer
    nodejs
    mongodb-tools
    networkmanagerapplet
  ];

  # Sunshine remote desktop
  # environment.variables.MUTTER_DEBUG_DISABLE_HW_CURSORS = "1";
  # environment.sessionVariables.MUTTER_DEBUG_DISABLE_HW_CURSORS = "1";
  # systemd.services.sunshine = {
  #   description = "Sunshine self-hosted game stream host for Moonlight.";
  #   after = ["graphical.target"];
  #   wantedBy = ["graphical.target"];
  #   startLimitIntervalSec = 500;
  #   startLimitBurst = 5;
  #   serviceConfig = {
  #     ExecStart = "${pkgs.sunshine}/bin/sunshine";
  #     Restart = "on-failure";
  #     RestartSec = "5s";
  #   };
  # };

  # Enable RDP through GNOME remote desktop
  services.gnome.gnome-remote-desktop.enable = true;
  networking.firewall.allowedTCPPorts = [3389];
  networking.firewall.allowedUDPPorts = [3389];

  # networking.interfaces.enp2s0.useDHCP = true;
  # networking.interfaces.br0.useDHCP = true;
  # networking.bridges = {
  #   "br0" = {
  #     interfaces = ["enp2s0"];
  #   };
  # };
  # networking.interfaces.br0.ipv4.addresses = [
  #   {
  #     address = "192.168.0.144";
  #     prefixLength = 24;
  #   }
  # ];

  # Machine specific aliases
  environment.shellAliases = {
    nix-switch = "sudo nixos-rebuild switch --flake ${outputs.flake-path}#lepus";
    home-switch = "home-manager switch --flake ${outputs.flake-path}#ben@lepus";
  };
}
