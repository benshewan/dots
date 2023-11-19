{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./hardware.nix
    ../shared
    ../shared/desktop-enviroments/hyprland.nix
  ];

  # System
  networking.hostName = "navis";

  # Remote management of Navis
  services.tailscale.enable = true;

  environment.systemPackages = with pkgs; [
    # Audio Configuration https://github.com/ceiphr/ee-framework-presets
    easyeffects
    powertop
    nm-tray
    masterpdfeditor
    stable.nodejs
    mongodb-tools
    moonlight-qt
    inkscape
  ];

  services.mongodb = {
    enable = true;
    package = pkgs.stable.mongodb;
  };

  systemd.sleep.extraConfig = ''
     HibernateDelaySec=30s # very low value to test suspend-then-hibernate
    # SuspendState=mem # suspend2idle is buggy :(
  '';
}
