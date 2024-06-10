{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.night-sky.programs.thunar;
in {
  options.night-sky.programs.thunar = {
    enable = lib.mkEnableOption "thunar";
  };

  config = lib.mkIf cfg.enable {
    services.gvfs.enable = true; # Mount, trash, and other functionalities
    services.tumbler.enable = true; # Thumbnail support for images
    programs.thunar.enable = true;
    programs.thunar.plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];

    environment.systemPackages = with pkgs; [
      gnome.file-roller
    ];
  };
}
