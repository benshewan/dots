{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.night-sky.programs.virt-manager;
  inherit (pkgs.stdenv) isLinux;
in {
  options.night-sky.programs.virt-manager = {
    enable = lib.mkEnableOption "virt-manager";
  };

  config = lib.mkIf (cfg.enable && isLinux) {
    home.packages = with pkgs; [
      virt-manager
    ];

    # Set default connection
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = ["qemu:///system"];
        uris = ["qemu:///system"];
      };
    };
  };
}
