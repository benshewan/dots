{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.night-sky.programs.vivaldi;
in {
  options.night-sky.programs.vivaldi = {
    enable = lib.mkEnableOption "vivaldi";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      (vivaldi.override {
        proprietaryCodecs = true; # causes some crashes with certain video sites
        enableWidevine = true;
        commandLineArgs = "--enable-features=WebUIDarkMode --force-dark-mode --ozone-platform-hint=auto --gtk-version=4 --enable-features=PlatformHEVCDecoderSupport";
      })
    ];
  };
}
