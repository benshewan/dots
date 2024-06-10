{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.night-sky.programs.thunderbird;
in {
  options.night-sky.programs.thunderbird = {
    enable = lib.mkEnableOption "thunderbird";
  };

  config = lib.mkIf cfg.enable {
    programs.thunderbird = {
      enable = true;
      package = pkgs.thunderbird.override {
        extraPolicies = {
          DontCheckDefaultBrowser = true;
        };
      };
      profiles = {
        default = {
          isDefault = true;
        };
      };
    };
  };
}
