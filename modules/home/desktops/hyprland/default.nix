{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.night-sky.desktops.hyprland;
in {
  options.night-sky.desktops.hyprland = {
    enable = lib.mkEnableOption "hyprland";
  };

  imports = [
    # Hyprland config
    ./keybinds.nix
    ./window-rules.nix
  ];

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      wl-clipboard # Clipboard helper
      cliphist
      stable.pavucontrol # Audio Control
      brightnessctl
      loupe
      foliate

      # Can't really replace hyprshade right now but is cool in that it wont effect screenshots or recordings
      inputs.hyprsunset.packages.${system}.hyprsunset

      libnotify # Send notifications
      kdePackages.xwaylandvideobridge # Allow XWayland apps to view wayland apps and desktops

      inputs.hyprland-qtutils.packages.${system}.hyprland-qtutils
    ];

    wayland.windowManager.hyprland.enable = true;
    wayland.windowManager.hyprland.systemd.enable = false;

    wayland.windowManager.hyprland.plugins = [
      # inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces
    ];
    services.hyprpaper = {
      enable = true;
      settings = {
        preload = ["${config.stylix.image}"];
        wallpaper = [",${config.stylix.image}"];
      };
    };

    # Base config taken from github:redyf/nixdots and mixed with github:justinlime/dotfiles
    wayland.windowManager.hyprland.settings = {
      exec-once = [
        # System
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP" # allow xdg portal to get the varibales it needs

        "${pkgs.udiskie}/bin/udiskie --file-manager dolphin &"
        # "${lib.getExe' pkgs.nm-tray "nm-tray"}" # Not working

        # Clipboard
        "${lib.getExe pkgs.wl-clip-persist} --clipboard both"
        "wl-paste --type text --watch ${lib.getExe pkgs.cliphist} store"
        "wl-paste --type image --watch ${lib.getExe pkgs.cliphist} store"

        # Style
        "${lib.getExe pkgs.dunst}"
        ''hyprctl setcursor "${config.stylix.cursor.name}" ${toString config.stylix.cursor.size}''
        # "swaync"
      ];

      plugin = {
        split-monitor-workspaces.count = 10;
        split-monitor-workspaces.keep_focused = true;
      };

      xwayland = {
        force_zero_scaling = true;
      };

      input = {
        kb_layout = "us";

        follow_mouse = 1;
        repeat_delay = 300;
        repeat_rate = 25;
        numlock_by_default = 1;
        accel_profile = "flat";
        sensitivity = 0;
        touchpad = {
          natural_scroll = 1;
          scroll_factor = 0.2;
          drag_lock = true;
        };
      };

      gestures = {
        workspace_swipe = true;
      };

      general = {
        gaps_in = 2;
        gaps_out = 4;
        border_size = 1;
        layout = "master";
      };

      master = {
        mfact = 0.5;
      };

      decoration = {
        rounding = 8;
        shadow = {
          enabled = true; # Power hungry effect
          ignore_window = true;
          render_power = 2;
          range = 15;
        };
        blur = {
          enabled = true; # Power hungry effect
          size = 6;
          passes = 3;
          new_optimizations = true;
          ignore_opacity = true;
          noise = 0.0117;
          contrast = 1.5;
          brightness = 1;
        };
      };

      animations = {
        enabled = true;
        # Selmer443 config
        bezier = [
          "pace,0.46, 1, 0.29, 0.99"
          "overshot,0.13,0.99,0.29,1.1"
          "md3_decel, 0.05, 0.7, 0.1, 1"
        ];
        animation = [
          "windowsIn,1,6,md3_decel,slide"
          "windowsOut,1,6,md3_decel,slide"
          "windowsMove,1,6,md3_decel,slide"
          "fade,1,10,md3_decel"
          "workspaces,1,9,md3_decel,slide"
          "workspaces, 1, 6, default"
          "specialWorkspace,1,8,md3_decel,slide"
          "border,1,10,md3_decel"
        ];
      };

      misc = {
        vfr = true; # misc:no_vfr -> misc:vfr. bool, heavily recommended to leave at default on. Saves on CPU usage.
        vrr = 0; # misc:vrr -> Adaptive sync of your monitor. 0 (off), 1 (on), 2 (fullscreen only). Default 0 to avoid white flashes on select hardware.

        # Stops hypr-chan from appearing when resizing firefox
        disable_hyprland_logo = true;
        # force_hypr_chan = false;
      };

      # Dynamic settings
      monitor =
        (map (
          m: let
            resolution = "${toString m.width}x${toString m.height}@${toString m.refreshRate}";
            position = "${toString m.x}x${toString m.y}";
            scale = toString m.scale;
            rotate = "transform," + toString m.rotate;
          in "${m.name},${
            if m.enabled
            then "preferred,${position},${scale},${rotate}"
            else "disable"
          }"
        ) (config.monitors))
        # set default for any random monitor
        ++ [",preferred,auto-right,auto"];

      workspace = map (
        m: "${m.name},${m.workspace}"
      ) (lib.filter (m: m.enabled && m.workspace != null) config.monitors);
    };
  };
}
