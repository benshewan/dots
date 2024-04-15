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

    # Helper apps
    ./waybar
    ./dunst
    # ./swaylock.nix
    ./hyprlock
    ./swayidle.nix
    ./rofi
  ];

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      wl-clipboard # Clipboard helper
      cliphist
      stable.pavucontrol # Audio Control
      loupe
      foliate
      libnotify # Send notifications
      xwaylandvideobridge # Allow XWayland apps to view wayland apps and desktops

      nwg-displays # GUI to configure screens
      wlr-randr # dependency of nwg-displays
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    };

    home.sessionVariables = {
      GRIMBLAST_EDITOR = lib.getExe pkgs.swappy;
    };

    wayland.windowManager.hyprland.plugins = [
      # inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces
    ];

    # Base config taken from github:redyf/nixdots and mixed with github:justinlime/dotfiles
    wayland.windowManager.hyprland.settings = {
      exec-once = [
        # System
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP" # allow xdg portal to get the varibales it needs
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
        "${lib.getExe config.services.swayidle.package}"
        "${pkgs.udiskie}/bin/udiskie --file-manager dolphin &"
        "${lib.getExe' pkgs.nm-tray "nm-tray"}"
        # "${pkgs.nm-tray}/bin/nm-tray" # Not working

        # Clipboard
        "${lib.getExe pkgs.wl-clip-persist} --clipboard both"
        "wl-paste --type text --watch ${lib.getExe pkgs.cliphist} store"
        "wl-paste --type image --watch ${lib.getExe pkgs.cliphist} store"

        # Style
        "${lib.getExe pkgs.dunst}"
        "${lib.getExe pkgs.waybar}"
        "${lib.getExe pkgs.swaybg} -i ${config.stylix.image} --mode fill"
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
        force_no_accel = 1;
        touchpad = {
          natural_scroll = 1;
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
        apply_sens_to_raw = 1; # whether to apply the sensitivity to raw input (e.g. used by games where you aim using your mouse)
      };

      master = {
        mfact = 0.5;
      };

      decoration = {
        rounding = 8;
        shadow_ignore_window = true;
        drop_shadow = true; # Power hungry effect
        shadow_range = 15;
        shadow_render_power = 2;
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
            then "${resolution},${position},${scale},${rotate}"
            else "disable"
          }"
        ) (config.monitors))
        # set default for any random monitor
        ++ [",preferred,auto,1"];

      workspace = map (
        m: "${m.name},${m.workspace}"
      ) (lib.filter (m: m.enabled && m.workspace != null) config.monitors);
    };
  };
}
