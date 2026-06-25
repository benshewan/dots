{inputs, ...} @ flake: {
  flake-file.inputs = {
    mangowm.url = "github:mangowm/mango";
    mangowm.inputs.nixpkgs.follows = "nixpkgs";
  };
  # NixOS
  flake.modules.nixos."window-managers/mangowm" = {
    pkgs,
    config,
    lib,
    ...
  }: {
    imports = [inputs.mangowm.nixosModules.mango];

    programs.dconf.enable = true;

    # enable ddc control
    hardware.i2c.enable = true;
    users.users.${flake.config.flake.meta.user.username}.extraGroups = ["i2c" "video"];

    programs.mango.enable = true;
    # Required Services
    # ----------------------------------------
    services.gnome.gnome-keyring.enable = true; # Store secrets securely (Wifi passwords,git tokens, etc...)
    services.gnome.gcr-ssh-agent.enable = lib.mkForce false;

    programs.seahorse.enable = true; # Manage Keys with a GUI
    programs.gnupg.agent.pinentryPackage = pkgs.pinentry-qt;

    # UI
    # ----------------------------------------

    environment.systemPackages = with pkgs; [
      adwaita-icon-theme
    ];
  };
  flake.modules.homeManager."window-managers/mangowm" = {
    pkgs,
    lib,
    config,
    ...
  }: {
    imports = [inputs.mangowm.hmModules.mango];

    wayland.windowManager.mango = {
      enable = true;
      systemd.enable = true; # Import important vars
      systemd.xdgAutostart = true; # allow apps to autostart with systemd
    };

    wayland.windowManager.mango.settings = {
      # Support for xwayland
      env = ["DISPLAY,:2"];
      exec-once = [
        "systemctl --user start mango-session.target"
        "${lib.getExe pkgs.xwayland-satellite} :2"
      ];

      # style
      blur = 1;
      blur_optimized = 1;
      blur_params = {
        radius = 5;
        num_passes = 2;
      };
      border_radius = 3;
      borderpx = 2;
      focused_opacity = 1.0;
      cursor_size = config.stylix.cursor.size;
      cursor_theme = config.stylix.cursor.name;

      gappih = 3; # inner horizontal
      gappiv = 3; # inner vertical
      gappoh = 3; # outer horizontal
      gappov = 3; # outer vertical

      ov_tab_mode = 0; # don't cycle with toggleoverview
      # mouse general
      focus_cross_monitor = 1; # Allow directional focus to cross monitor boundaries.
      drag_tile_to_tile = 1; # Allow dragging a tiled window onto another to swap their positions.
      drag_warp_cursor = 1; # Prevent the window from snapping by warping the cursor to that corner
      # Mouse input
      axis_scroll_factor = 2;
      mouse_accel_profile = 0;
      # trackpad input
      trackpad_natural_scrolling = 1;
      trackpad_scroll_factor = 0.5;
      tap_to_click = 1;
      tap_and_drag = 1;

      # Animations
      animations = 1;

      animation_type_open = "slide";
      animation_duration_open = 400;

      animation_type_close = "slide";
      animation_duration_close = 400;

      # Binds - placeholder
      bind =
        # Standard navigation
        (map (i: "SUPER,${toString i},view,${toString i}") ((lib.range 1 9) ++ [0]))
        ++ (map (i: "SUPER+SHIFT,${toString i},tagsilent,${toString i}") ((lib.range 1 9) ++ [0]))
        ++ [
          "SUPER+SHIFT,left,tagmon,left"
          "SUPER+SHIFT,right,tagmon,right"
          "SUPER+SHIFT,up,tagmon,up"
          "SUPER+SHIFT,down,tagmon,down"

          "SUPER,left,focusdir,left"
          "SUPER,right,focusdir,right"
          "SUPER,up,focusdir,up"
          "SUPER,down,focusdir,down"
          "SUPER+ALT,left,focusmon,left"
          "SUPER+ALT,right,focusmon,right"
          "SUPER+ALT,up,focusmon,up"
          "SUPER+ALT,down,focusmon,down"

          "SUPER,Q,killclient"
          "SUPER,M,quit"
          "SUPER,F,togglefloating"
          "SUPER+SHIFT,Q,killclient,force"
          "SUPER,tab,toggleoverview"
          "SUPER,l,spawn,${lib.getExe config.programs.hyprlock.package} --grace 0"

          "SUPER,Return,spawn,${lib.getExe pkgs.kitty}"
          "SUPER,e,spawn,${lib.getExe pkgs.kitty} -e ${lib.getExe config.programs.yazi.package}"
          "SUPER,r,reload_config"

          # noctalia
          "SUPER,space,spawn,${lib.getExe config.programs.noctalia.package} msg panel-toggle launcher"
          "SUPER,v,spawn,${lib.getExe config.programs.noctalia.package} msg panel-toggle clipboard"
          "SUPER,s,spawn,${lib.getExe config.programs.noctalia.package} msg screenshot-region"
          "SUPER+SHIFT,s,spawn,${lib.getExe config.programs.noctalia.package} msg screenshot-fullscreen"

          "NONE,XF86AudioRaiseVolume,spawn,${lib.getExe config.programs.noctalia.package} msg volume-up"
          "NONE,XF86AudioLowerVolume,spawn,${lib.getExe config.programs.noctalia.package} msg volume-down"
          "NONE,XF86AudioMute,spawn,${lib.getExe config.programs.noctalia.package} msg volume-mute"
          "NONE,XF86MonBrightnessUp,spawn,${lib.getExe config.programs.noctalia.package} msg brightness-up"
          "NONE,XF86MonBrightnessDown,spawn,${lib.getExe config.programs.noctalia.package} msg brightness-down"
        ];

      mousebind = [
        "SUPER,btn_left,moveresize,curmove"
        "SUPER,btn_right,moveresize,curresize"
      ];

      gesturebind = [
        "none,right,3,viewtoleft_have_client"
        "none,left,3,viewtoright_have_client"
        "none,up,3,toggleoverview"
        "none,down,3,toggleoverview"
      ];

      switchbind = lib.flatten (map (
          m:
            if lib.strings.hasInfix "eDP-1" m.name
            then [
              "fold,spawn,${lib.getExe pkgs.wlr-randr} --output eDP-1 --off"
              "unfold,spawn,${lib.getExe pkgs.wlr-randr} --output eDP-1 --on --pos ${toString m.x},${toString m.y} --scale ${toString m.scale} --mode ${toString m.width}x${toString m.height}"
            ]
            else []
        )
        config.monitors);

      tagrule = [
        "id:1,layout_name:fair"
        "id:2,layout_name:fair"
        "id:3,layout_name:fair"
        "id:4,layout_name:fair"
        "id:5,layout_name:fair"
        "id:6,layout_name:fair"
        "id:7,layout_name:fair"
        "id:8,layout_name:fair"
        "id:9,layout_name:fair"
      ];

      monitorrule = map (
        m: let
          resolution = "width:${toString m.width},height:${toString m.height},refresh:${toString m.refreshRate}";
          position = "x:${toString m.x},y:${toString m.y}";
          scale = "scale:${toString m.scale}";
        in "${config.lib.monitors.mangoName m.name},${resolution},${position},${scale}"
      ) (config.monitors);
    };
  };
}
