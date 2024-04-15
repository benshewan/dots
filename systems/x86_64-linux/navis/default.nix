{
  pkgs,
  outputs,
  lib,
  ...
}: {
  imports = [
    # "${outputs.src}/themes/gruvbox/nixos"
    ./hardware-configuration.nix
    ./hardware.nix
  ];

  # System
  networking.hostName = "navis";
  night-sky.desktops.hyprland.enable = true;

  # # Remote management of Navis
  # services.tailscale.enable = true;

  # environment.systemPackages = with pkgs;
  #   [
  #     # Audio Configuration https://github.com/ceiphr/ee-framework-presets
  #     easyeffects
  #     powertop
  #     nm-tray
  #   ]
  #   # Development stuff
  #   ++ (with pkgs; [
  #     stable.nodejs
  #     mongodb-tools
  #   ]);

  # programs.goldwarden = {
  #   enable = true;
  #   useSshAgent = true;
  # };

  # # Networking stuff
  # networking.extraHosts =
  #   (lib.concatMapStrings (x: "100.68.3.84 " + x + ".benshewan.dev\n") [
  #     "plex"
  #     "sonarr"
  #     "radarr"
  #     "prowlarr"
  #     "overseerr"
  #     "downloads"
  #     "auth"
  #     "tautulli"
  #     "invite"
  #     "portainer"
  #     "files"
  #     "admin"
  #     "stats"
  #     "nzb"
  #     "jellyfin"
  #   ])
  #   + '''';

  # # Work
  # services.mongodb = {
  #   enable = true;
  #   package = pkgs.stable.mongodb;
  # };

  # services.teamviewer.enable = true;

  # MongoDB Extenal access
  # MongoDB port [27017]
  # services.mongodb.bind_ip = "127.0.0.1,192.168.0.69";
  # services.mongodb.enableAuth = false;
  # services.mongodb.initialRootPassword = "Coldsteel@22";
}
