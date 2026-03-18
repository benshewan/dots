{inputs, ...}: {
  flake-file.inputs = {
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-qtutils.url = "github:hyprwm/hyprland-qtutils";
  };
  # NixOS
  flake.modules.nixos."window-managers/hyprland" = {
    pkgs,
    config,
    ...
  }: let
    inherit (pkgs.stdenv.hostPlatform) system;
  in {
    programs.uwsm.enable = true;
    programs.dconf.enable = true;
    programs.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${system}.hyprland; # Unstable
      portalPackage = inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland;
      withUWSM = true;
    };

    # Required Services
    # ----------------------------------------
    services.gnome.gnome-keyring.enable = true; # Store secrets securely (Wifi passwords,git tokens, etc...)

    programs.seahorse.enable = true; # Manage Keys with a GUI
    services.blueman.enable = true; # GTK Bluetooth manager
    programs.gnupg.agent.pinentryPackage = pkgs.pinentry-qt;

    services.udisks2.enable = true; # Auto mount removable drives on connect
    # services.udisks2.settings = {
    #   "drive.conf".ATA.WriteCacheEnabled = false;
    # };

    xdg.portal = {
      enable = true;
      extraPortals = [
        inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-gtk
      ];
    };

    # UI
    # ----------------------------------------
    programs.waybar.enable = true;

    environment.systemPackages = with pkgs; [
      adwaita-icon-theme
    ];

    # For GUI sudo authentication
    # ----------------------------------------
    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = ["graphical-session.target"];
      wants = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    # Add lock screen to pam for authentication
    # ----------------------------------------
    security.pam.services = {
      hyprland.enableGnomeKeyring = true;
      hyprlock = {
        enableGnomeKeyring = true;
        text = ''
          auth include login
          account include login
        '';
      };
      hypridle = {};
    };
  };
  flake.modules.homeManager."window-managers/hyprland" = {
    pkgs,
    lib,
    config,
    ...
  }: {
    wayland.windowManager.hyprland.enable = true;
    wayland.windowManager.hyprland.systemd.enable = false;

    home.packages = with pkgs; [
      libnotify # Send notifications

      inputs.hyprland-qtutils.packages.${stdenv.hostPlatform.system}.hyprland-qtutils
    ];

    # Setup wallpaper
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
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP" # allow xdg portal to get the variables it needs

        "${pkgs.udiskie}/bin/udiskie --file-manager dolphin &"

        # Clipboard
        "${lib.getExe pkgs.wl-clip-persist} --clipboard both"
        "${lib.getExe' pkgs.wl-clipboard "wl-paste"} --type text --watch ${lib.getExe pkgs.cliphist} store"
        "${lib.getExe' pkgs.wl-clipboard "wl-paste"} --type image --watch ${lib.getExe pkgs.cliphist} store"

        # Style
        "${lib.getExe pkgs.dunst}"
        ''hyprctl setcursor "${config.stylix.cursor.name}" ${toString config.stylix.cursor.size}''
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

        disable_hyprland_logo = true;
      };

      # Dynamic settings
      monitor =
        (map (
          m: let
            resolution = "${toString m.width}x${toString m.height}@${toString m.refreshRate}";
            position = "${toString m.x}x${toString m.y}";
            scale = toString m.scale;
            rotate = "transform," + toString m.rotate;
            colorProfile =
              "cm, "
              + m.colorProfile
              + (
                if m.colorProfile == "hdr" || m.colorProfile == "hdredid"
                then ", bitdepth, 10"
                else ""
              );
          in "${m.name},${
            if m.enabled
            then "${resolution},${position},${scale},${rotate},${colorProfile}"
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
