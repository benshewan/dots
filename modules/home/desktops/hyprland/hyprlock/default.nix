{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: let
  colors = config.lib.stylix.colors;
in {
  imports = [
    inputs.hyprlock.homeManagerModules.default
  ];

  config = lib.mkIf config.wayland.windowManager.hyprland.enable {
    home.packages = with pkgs; [
      material-symbols
    ];
    programs.hyprlock = {
      enable = true;

      general = {
        grace = 5;
        hide_cursor = true;
        ignore_empty_input = true;
      };

      backgrounds = [
        {
          path = config.stylix.image;
          blur_size = 5;
          blur_passes = 4;
        }
      ];

      images = [];

      input-fields = [
        {
          size.width = 350;
          size.height = 50;
          outline_thickness = 2;
          dots_size = 0.1;
          dots_spacing = 0.3;
          outer_color = "rgba(${colors.base01}55)";
          inner_color = "rgba(${colors.base00}11)";
          font_color = "rgba(${colors.base0A}FF)";
          fade_on_empty = false;
          placeholder_text = "";
          position.x = 0;
          position.y = 20;
          halign = "center";
          valign = "center";
        }
      ];

      labels = [
        {
          # Clock
          text = "$TIME";
          shadow_passes = 1;
          shadow_boost = 0.5;
          color = "rgba(${colors.base05}FF)";
          font_size = 65;
          font_family = config.stylix.fonts.sansSerif.name;
          position.x = 0;
          position.y = 300;
          halign = "center";
          valign = "center";
        }
        {
          # Greeting
          text = "Hello $DESC";
          shadow_passes = 1;
          shadow_boost = 0.5;
          color = "rgba(${colors.base05}FF)";
          font_size = 20;
          font_family = config.stylix.fonts.sansSerif.name;
          position.x = 0;
          position.y = 75;
          halign = "center";
          valign = "center";
        }
        {
          # Locked icon
          text = "lock";
          shadow_passes = 1;
          shadow_boost = 0.5;
          color = "rgba(${colors.base05}FF)";
          font_size = 21;
          font_family = "Material Symbols Rounded";
          position.x = 0;
          position.y = 70;
          halign = "center";
          valign = "bottom";
        }
        {
          # "Locked" text
          text = "Locked";
          shadow_passes = 1;
          shadow_boost = 0.5;
          color = "rgba(${colors.base05}FF)";
          font_size = 14;
          font_family = config.stylix.fonts.sansSerif.name;
          position.x = 0;
          position.y = 50;
          halign = "center";
          valign = "bottom";
        }
        {
          # Status
          text = "cmd[update:1000] ${./status.sh}";
          shadow_passes = 1;
          shadow_boost = 0.5;
          color = "rgba(${colors.base05}FF)";
          font_size = 14;
          font_family = config.stylix.fonts.sansSerif.name;
          position.x = 30;
          position.y = -30;
          halign = "left";
          valign = "top";
        }
      ];
    };
  };
}
