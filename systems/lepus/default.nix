{
  inputs,
  outputs,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    # Note: seems that having netowrk shares makes nautilus take forever to start
    # ./networking.nix
    ../shared
    ../shared/desktop-enviroments/gnome.nix
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.common-cpu-intel
  ];

  # System
  networking.hostName = "lepus";

  # Low memory hurts FreeCore development
  # Note: seems to cause random full systems freezes, presumably due to OOM Management
  zramSwap.enable = true;

  nixpkgs.overlays = [outputs.overlays.additions];
  # Remote Management
  services.tailscale.enable = true;
  services.mongodb.enable = true;
  environment.systemPackages = with pkgs; [
    trayscale
    inkscape
    ppsspp
    # wisenet-viewer
    nodejs
    mongodb-tools
    networkmanagerapplet
  ];

  virtualisation.waydroid.enable = true;

  # Sunshine remote desktop
  # Note: works great just wasn't working through tailscale
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

  # I'll admit that I can't seem to figure out kvm network bridges, so I guess I'm using this for now.
  # Warning: will need to be built from source since it's unfree, so expect a lot of waiting.
  #  users.${outputs.username}.extraGroups = ["vboxusers"];
  #   virtualisation.virtualbox.host = {
  #     enable = true;
  #     enableExtensionPack = true;
  #   };

  # Machine specific aliases
  environment.shellAliases = {
    nix-switch = "sudo nixos-rebuild switch --flake ${outputs.flake-path}#lepus";
    home-switch = "home-manager switch --flake ${outputs.flake-path}#ben@lepus";
  };
}
