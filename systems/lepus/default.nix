{ inputs, outputs, pkgs, config, lib, ... }:
let
  pwfile = "/home/${outputs.username}/.vnc/passwd"; # vncpasswd
  pwtmp = "/tmp/vnc-password";
  vnc_port = 5900;
in
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
      # User = outputs.username;
      ExecStart = "${pkgs.sunshine}/bin/sunshine";
      # PermissionsStartOnly = true;
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
  # systemd.services = {
  #   # TODO: terminal-server without a real gui and virtual display manager
  #   terminal-server = {
  #     description = "VNC Terminal Server";
  #     after = [ "display-manager.service" "graphical.target" ];
  #     wantedBy = [ "multi-user.target" ];
  #     serviceConfig = {
  #       User = outputs.username;
  #       Restart = "always";
  #       ExecStartPre = pkgs.writers.writeDash "terminal-pre" ''
  #         sleep 5
  #         install -m0700 -o ${outputs.username} ${pwfile} ${pwtmp}
  #       '';
  #       ExecStart = "${pkgs.tigervnc}/bin/x0vncserver -display :0 -rfbport ${toString vnc_port}";
  #       PermissionsStartOnly = true;
  #       PrivateTmp = true;
  #     };
  #   };
  # };
  networking.firewall.allowedTCPPorts = [ 47984 47989 ];

  environment.shellAliases = {
    nix-switch = "sudo nixos-rebuild switch --flake ${outputs.flake-path}#lepus";
    home-switch = "home-manager switch --flake ${outputs.flake-path}#ben@lepus";
  };
}
