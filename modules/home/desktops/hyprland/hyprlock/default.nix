{
  config,
  pkgs,
  lib,
  ...
}: let
  colors = config.lib.stylix.colors;
in {
  config = lib.mkIf config.wayland.windowManager.hyprland.enable {
    stylix.targets.hyprlock.enable = false;
    home.packages = with pkgs; [
      material-symbols
    ];

    # To unstick hyprlock if you get the red screen of death
    home.shellAliases."hyprlock-unlock" = "pkill -USR1 hyprlock";

    programs.hyprlock = {
      enable = true;

      settings = {
        general = {
          grace = 5;
          hide_cursor = true;
          ignore_empty_input = true;
        };

        background = [
          {
            path = toString config.stylix.image;
            blur_size = 5;
            blur_passes = 4;
          }
        ];

        image = [];

        input-field = with colors; [
          {
            position = "0, 20";
            size = "350, 50";
            outline_thickness = 2;
            dots_size = 0.1;
            dots_spacing = 0.3;
            outer_color = "rgb(${base03})";
            inner_color = "rgb(${base00})";
            font_color = "rgb(${base05})";
            fail_color = "rgb(${base08})";
            check_color = "rgb(${base0A})";
            fade_on_empty = false;
            placeholder_text = "";
            halign = "center";
            valign = "center";
          }
        ];

        label = [
          {
            # Clock
            text = "$TIME";
            position = "0, 300";
            shadow_passes = 1;
            shadow_boost = 0.5;
            color = "rgba(${colors.base05}FF)";
            font_size = 65;
            font_family = config.stylix.fonts.sansSerif.name;
            halign = "center";
            valign = "center";
          }
          {
            # Greeting
            text = "Hello $DESC";
            position = "0, 75";
            shadow_passes = 1;
            shadow_boost = 0.5;
            color = "rgba(${colors.base05}FF)";
            font_size = 20;
            font_family = config.stylix.fonts.sansSerif.name;
            halign = "center";
            valign = "center";
          }
          {
            # Locked icon
            text = "lock";
            position = "0, 70";
            shadow_passes = 1;
            shadow_boost = 0.5;
            color = "rgba(${colors.base05}FF)";
            font_size = 21;
            font_family = "Material Symbols Rounded";
            halign = "center";
            valign = "bottom";
          }
          {
            # "Locked" text
            text = "Locked";
            position = "0, 50";
            shadow_passes = 1;
            shadow_boost = 0.5;
            color = "rgba(${colors.base05}FF)";
            font_size = 14;
            font_family = config.stylix.fonts.sansSerif.name;
            halign = "center";
            valign = "bottom";
          }
          {
            # Status
            text = "cmd[update:1000] ${./status.sh}";
            position = "30, -30";
            shadow_passes = 1;
            shadow_boost = 0.5;
            color = "rgba(${colors.base05}FF)";
            font_size = 14;
            font_family = config.stylix.fonts.sansSerif.name;
            halign = "left";
            valign = "top";
          }
        ];
      };
    };
  };
}
