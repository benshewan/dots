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

    programs.mango = {
      enable = true;
    };

    # Required Services
    # ----------------------------------------
    services.gnome.gnome-keyring.enable = true; # Store secrets securely (Wifi passwords,git tokens, etc...)
    services.gnome.gcr-ssh-agent.enable = lib.mkForce false;

    programs.seahorse.enable = true; # Manage Keys with a GUI
    programs.gnupg.agent.pinentryPackage = pkgs.pinentry-qt;

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-wlr
      ];
      wlr.settings.preferred = {
        default = "gtk";
        "org.freedesktop.impl.portal.SecreenCast" = "wlr";
        "org.freedesktop.impl.portal.Screenshot" = "wlr";
        "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
        "org.freedesktop.impl.portal.Inhibit" = "none";
      };
    };

    # UI
    # ----------------------------------------

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
      # Script to run at startup
      # autostart_sh = ''

      # '';
    };

    wayland.windowManager.mango.settings = {
      # exec-once = [
      #   "${lib.getExe pkgs.dunst}"
      # ];

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

      # Animations
      animations = 1;

      animation_type_open = "slide";
      animation_duration_open = 400;

      animation_type_close = "slide";
      animation_duration_close = 800;

      # Binds - placeholder
      bind =
        # Standard navigation
        (map (i: "SUPER,${toString i},view,${toString i}") ((lib.range 1 9) ++ [0]))
        ++ (map (i: "SUPER+SHIFT,${toString i},tagslient,${toString i}") ((lib.range 1 9) ++ [0]))
        ++ [
          "SUPER,Q,killclient"
          "SUPER,F,togglefloating"
          "SUPER+SHIFT,Q,killclient,force"

          "SUPER,Return,spawn,${lib.getExe pkgs.kitty}"
          "SUPER,r,reload_config"

          # noctalia
          "SUPER,space,spawn,${lib.getExe config.programs.noctalia.package} msg panel-toggle launcher"
          "SUPER,v,spawn,${lib.getExe config.programs.noctalia.package} msg panel-toggle clipboard"

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

      monitorrule = map (
        m: let
          resolution = "width:${toString m.width},height:${toString m.height},refresh:${toString m.refreshRate}";
          position = "x:${toString m.x},y:${toString m.y}";
          scale = "scale:${toString m.scale}";
        in "name:${m.name},${resolution},${position},${scale}"
      ) (config.monitors);
    };
  };
}
