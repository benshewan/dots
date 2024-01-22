{
  pkgs,
  lib,
  outputs,
  ...
}: {
  imports = [
    "${outputs.flake-path}/shared/nixos/desktops/hyprland"
    ./hardware-configuration.nix
    ./hardware.nix
    ../shared
  ];

  # System
  networking.hostName = "navis";

  # Remote management of Navis
  services.tailscale.enable = true;

  environment.systemPackages = with pkgs; [
    # Audio Configuration https://github.com/ceiphr/ee-framework-presets
    easyeffects
    goldwarden # a lightweight daemon to add functionallity missing from the native bitwarden client
    pinentry

    powertop
    nm-tray
    masterpdfeditor
    stable.nodejs
    mongodb-tools
    stable.moonlight-qt
    inkscape
  ];

  services.mongodb = {
    enable = true;
    package = pkgs.stable.mongodb;
  };
  services.teamviewer.enable = true;
  # networking.firewall.enable = false;
  # systemd.sleep.extraConfig = ''
  #    HibernateDelaySec=30s # very low value to test suspend-then-hibernate
  #   # SuspendState=mem # suspend2idle is buggy :(
  # '';
  # FreeCore testing
  networking.firewall.allowedTCPPorts =
    [7100 7200 443 80]
    /*
    ++ [27017]
    */
    ;
  # services.mongodb.bind_ip = "127.0.0.1,192.168.0.69";
  # services.mongodb.enableAuth = false;
  # services.mongodb.initialRootPassword = "Coldsteel@22";
}
