{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.night-sky.programs.chromium;
in {
  options.night-sky.programs.chromium = {
    enable = lib.mkEnableOption "chromium";
  };

  config = lib.mkIf cfg.enable {
    programs.chromium = {
      enable = true;
      # package = pkgs.thorium;
      commandLineArgs = ["--ozone-platform-hint=auto"];
    };
  };
}
