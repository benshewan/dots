{
  pkgs,
  config,
  lib,
  namespace,
  ...
}: let
  cfg = config.night-sky.programs.webstorm;
in {
  options.night-sky.programs.webstorm = {
    enable = lib.mkEnableOption "webstorm";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      (jetbrains.webstorm.override {
        vmopts = ''
          -Xmx4G
          -Xms2G
          -Dawt.toolkit.name=WLToolkit
        '';
      })
    ];
  };
}
