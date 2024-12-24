{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: let
  cfg = config.night-sky.programs.foot;
in {
  options.night-sky.programs.foot = {
    enable = lib.mkEnableOption "foot";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      foot = {
        enable = true;
        package = pkgs.foot;
        settings = {
        };
      };
    };
  };
}
