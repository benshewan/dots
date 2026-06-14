{inputs, ...} @ flake: {
  flake-file.inputs = {
    noctalia.url = "github:noctalia-dev/noctalia";
    noctalia.inputs.nixpkgs.follows = "nixpkgs";
  };
  flake.modules.homeManager."window-managers/mangowm" = {
    pkgs,
    lib,
    config,
    ...
  }: let
    c = config.lib.stylix.colors.withHashtag;
  in {
    imports = [inputs.noctalia.homeModules.default];

    wayland.windowManager.mango.settings.exec-once = ["${lib.getExe (config.programs.noctalia.package)}"];
    programs.noctalia = {
      enable = true;
      settings = {
        theme = {
          mode = "dark";
          source = "custom";
          custom_palette = "stylix";
        };
        bar.main = {
          position = "top";
          enabled = true;
          auto_hide = false;
          reserve_space = true;
          layer = "top";
          thickness = 34;
          background_opacity = 1.0;
          border = "outline";
          border_width = 0.0;
          shadow = true;
          margin_edge = 10;

          capsule = true;

          start = ["launcher" "workspaces"];
          center = ["clock"];
          end = ["media" "tray" "notifications" "clipboard" "network" "bluetooth" "volume" "brightness" "battery" "control-center" "session"];
        };
        wallpaper = {
          enabled = true;
          default.path = toString config.stylix.image;
        };
      };
      customPalettes.stylix = {
        dark = {
          mPrimary = c.base0D;
          mOnPrimary = c.base07;
          mSecondary = c.base0C;
          mOnSecondary = c.base07;
          mTertiary = c.base0E;
          mOnTertiary = c.base07;
          mError = c.base08;
          mOnError = c.base07;
          mSurface = c.base00;
          mOnSurface = c.base05;
          mSurfaceVariant = c.base01;
          mOnSurfaceVariant = c.base04;
          mOutline = c.base03;
          mShadow = c.base00;
          mHover = c.base02;
          mOnHover = c.base05;
          terminal = {
            background = c.base00;
            foreground = c.base05;
            cursor = c.base05;
            cursorText = c.base00;
            selectionBg = c.base05;
            selectionFg = c.base00;
            normal = {
              black = c.base00;
              red = c.base08;
              green = c.base0B;
              yellow = c.base0A;
              blue = c.base0D;
              magenta = c.base0E;
              cyan = c.base0C;
              white = c.base05;
            };
            bright = {
              black = c.base03;
              red = c.base08;
              green = c.base0B;
              yellow = c.base0A;
              blue = c.base0D;
              magenta = c.base0E;
              cyan = c.base0C;
              white = c.base07;
            };
          };
        };
        light = {
          mPrimary = c.base0D;
          mOnPrimary = c.base00;
          mSecondary = c.base0C;
          mOnSecondary = c.base00;
          mTertiary = c.base0E;
          mOnTertiary = c.base00;
          mError = c.base08;
          mOnError = c.base00;
          mSurface = c.base07;
          mOnSurface = c.base00;
          mSurfaceVariant = c.base06;
          mOnSurfaceVariant = c.base04;
          mOutline = c.base03;
          mShadow = c.base07;
          mHover = c.base06;
          mOnHover = c.base00;
          terminal = {
            background = c.base07;
            foreground = c.base00;
            cursor = c.base00;
            cursorText = c.base07;
            selectionBg = c.base00;
            selectionFg = c.base07;
            normal = {
              black = c.base07;
              red = c.base08;
              green = c.base0B;
              yellow = c.base0A;
              blue = c.base0D;
              magenta = c.base0E;
              cyan = c.base0C;
              white = c.base00;
            };
            bright = {
              black = c.base04;
              red = c.base08;
              green = c.base0B;
              yellow = c.base0A;
              blue = c.base0D;
              magenta = c.base0E;
              cyan = c.base0C;
              white = c.base00;
            };
          };
        };
      };
    };
  };
}
