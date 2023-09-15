{ inputs, outputs, pkgs, lib, ... }:
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

  # Remote Management
  services.tailscale.enable = true;
  environment.systemPackages = with pkgs;[
    trayscale
    sunshine
    gnome.gnome-remote-desktop
    inkscape
  ];
  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "gnome-xorg";
  services.xrdp.openFirewall = true;
  programs.gamescope.enable = true;
  networking.firewall.enable = lib.mkForce false;

  # Sunshine remote desktop
  environment.variables.MUTTER_DEBUG_DISABLE_HW_CURSORS = "1";
  environment.sessionVariables.MUTTER_DEBUG_DISABLE_HW_CURSORS = "1";
  systemd.services.sunshine = {
    description = "Sunshine self-hosted game stream host for Moonlight.";
    after = [ "graphical.target" ];
    wantedBy = [ "graphical.target" ];
    startLimitIntervalSec = 500;
    startLimitBurst = 5;
    serviceConfig = {
      ExecStart = "${pkgs.sunshine}/bin/sunshine";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
  networking.firewall.allowedTCPPorts = [ 47984 47989 ];

  # Machine specific aliases
  environment.shellAliases = {
    nix-switch = "sudo nixos-rebuild switch --flake ${outputs.flake-path}#lepus";
    home-switch = "home-manager switch --flake ${outputs.flake-path}#ben@lepus";
  };
}
