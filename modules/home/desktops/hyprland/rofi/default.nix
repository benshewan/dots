{
  pkgs,
  lib,
  config,
  ...
}: let
  # userChrome.js loader
  rofi-themes = pkgs.fetchFromGitHub {
    owner = "adi1090x";
    repo = "rofi";
    rev = "a3c2def145e354d3cb88fafbbccfe8bd37da88db";
    sha256 = "sha256-Ew3Po2y20OlOtiX08A4ySxvdLC9KTrNQd32SQZz6DJM=";
  };
  rofi-themes-test = builtins.readDir rofi-themes;
in {
  config = lib.mkIf config.night-sky.desktops.hyprland.enable {
    home.packages = with pkgs; [
      rofi-bluetooth
    ];

    # Install rofi themes
    home.file.".config/rofi" = {
      recursive = true;
      source = "${rofi-themes}/files";
    };

    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      location = "center";
      terminal = lib.getExe pkgs.kitty;

      plugins = with pkgs; [
        rofi-calc
        rofi-power-menu
      ];
    };
  };
}
