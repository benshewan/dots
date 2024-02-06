{
  pkgs,
  outputs,
  lib,
  ...
}: {
  imports = [
    "${outputs.flake-path}/shared/nixos/desktops/hyprland"
    "${outputs.flake-path}/shared/nixos/programs/thunar"
    "${outputs.flake-path}/shared/nixos/programs/dolphin"
    "${outputs.flake-path}/themes/gruvbox/nixos"
    ./hardware-configuration.nix
    ./hardware.nix
    ../shared
  ];

  # System
  networking.hostName = "navis";

  # Remote management of Navis
  services.tailscale.enable = true;

  environment.systemPackages = with pkgs;
    [
      # Audio Configuration https://github.com/ceiphr/ee-framework-presets
      easyeffects
      powertop
      nm-tray
    ]
    # Development stuff
    ++ (with pkgs; [
      stable.nodejs
      mongodb-tools
    ]);

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
  networking.firewall.allowedTCPPorts = [7100 7200 443 80];

  # MongoDB Extenal access
  # MongoDB port [27017]
  # services.mongodb.bind_ip = "127.0.0.1,192.168.0.69";
  # services.mongodb.enableAuth = false;
  # services.mongodb.initialRootPassword = "Coldsteel@22";

  # Networking stuff
  networking.extraHosts = lib.concatMapStrings (x: "100.68.3.84 " + x + ".benshewan.dev\n") [
    "plex"
    "sonarr"
    "radarr"
    "prowlarr"
    "overseerr"
    "downloads"
    "auth"
    "tautulli"
    "invite"
    "portainer"
    "files"
    "admin"
  ];
}
