{config, ...}: let
  # Flake-level user metadata; config.flake does not exist inside NixOS
  # modules, which shadow `config` with the host config.
  username = config.flake.meta.user.username;
in {
  flake.modules.homeManager."window-managers/mangowm" = {
    pkgs,
    lib,
    config,
    ...
  }: {
    wayland.windowManager.mango.settings.exec_once = ["${lib.getExe (config.programs.noctalia.package)}"];
    home.packages = with pkgs; [ddcutil]; # needed for ddc control
    programs.noctalia = {
      enable = true;
      settings = {
        # custom 12hr time widget
        widget.clock-12h = {
          type = "clock";
          format = "{:%-I:%M %p}";
        };
        widget.network.show_label = false; # don't show interface/network in bar
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
          shadow = false;
          margin_edge = 0; # gap from screen top, match mongo outer vertical gap
          margin_ends = 0; # gap from screen edge
          radius = 0; # disable radius
          # radius_bottom_left = -8;
          # radius_bottom_right = -8;

          capsule = true;

          start = ["workspaces"];
          center = ["clock-12h"];
          end = ["tray" "notifications" "caffeine" "network" "bluetooth" "volume" "brightness" "battery" "session"];
        };

        # Use Stylix wallpaper
        wallpaper = {
          enabled = true;
          default.path = toString config.stylix.image;
        };

        # Use satty for screenshot editing
        shell.screenshot = {
          save_to_file = false;
          pipe_to_command = true;
          pipe_command = "${lib.getExe pkgs.satty} -f -";
        };

        # enable DDC controls for real monitors
        brightness.enable_ddcutil = true;

        # Disable media playing osd
        osd.kinds.media = false;

        lockscreen.enabled = false;

        shell.animation.speed = 2.0;
        shell.clipboard_auto_paste = "off";
        shell.polkit_agent = true;
        shell.setup_wizard_enabled = false;
        shell.telemetry_enabled = false;
        shell.font_family = config.stylix.fonts.sansSerif.name;
      };

      # Follow Stylx for theming, thanks AI
      settings.theme = {
        mode = "dark";
        source = "custom";
        custom_palette = "stylix";
      };
    };
  };

  # Preservation companion for "window-managers/mangowm" (auto-resolved by the prefix).
  flake.modules.nixos."preservation/window-managers/mangowm" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username}.directories = [
      # Noctalia's settings.json is declarative, but its runtime state is
      # not. Lives under the window-manager key because that is the feature
      # the host resolves (noctalia is part of the mangowm module).
      ".local/state/noctalia"
    ];
  };
}
