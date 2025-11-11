{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.night-sky.home.extraOptions.night-sky.programs.yazi;
  inherit (pkgs.stdenv) isDarwin isLinux;
in {
  config = lib.mkIf (cfg.enable && isLinux) {
    services.gvfs.enable = true; # used for the gvfs.yazi plugin
    environment.systemPackages = with pkgs; [
      glib
      sshfs
    ];
  };
}
