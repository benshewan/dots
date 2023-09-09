{ custom ? {
    fontsize = "12";
    primary_accent = "cba6f7";
    secondary_accent = "89b4fa";
    tertiary_accent = "f5f5f5";
    background = "11111B";
    opacity = ".85";
    cursor = "Numix-Cursor";
  }
, ...
}:
{
  imports = [ 
    ./waybar.nix 
    ./wofi.nix
    ];

  wayland.windowManager.hyprland = {
    enable = true;

    # Base config taken from github:redyf/nixdots and mixed with github:justinlime/dotfiles
    settings = {

      monitor = [
        "DP-2, 1920x1080@75,1920x0,1"
        "HDMI-A-2, 1920x1080@75,0x0,1"
        ",preferred,auto,auto"
      ];

      exec-once = [
        "waybar"
        "swaybg -i ${../../../../wallpapers/nix-black-4k.png}"
        # ''swayidle -w timeout 1800 'swaylock -f -i ~/photos/wallpapers/wallpaper.png' timeout 1805 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' before-sleep "swaylock -f -i ~/photos/wallpapers/wallpaper.png"''
        "hyprctl setcursor ${custom.cursor} ${custom.fontsize}"
        # "swaync"
      ];

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

      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 1;
        # "col.active_border" = "rgb(${custom.primary_accent})";
        "col.active_border" = "rgb(${custom.background})";
        "col.inactive_border" = "rgba(${custom.background}00)";
        layout = "master";
        apply_sens_to_raw = 1; # whether to apply the sensitivity to raw input (e.g. used by games where you aim using your mouse)
      };

      decoration = {
        rounding = 10;
        multisample_edges = true;
        shadow_ignore_window = true;
        drop_shadow = true;
        shadow_range = 15;
        shadow_render_power = 2;
        # "col.shadow" = "rgb(${custom.primary_accent})";
        "col.shadow" = "rgb(${custom.background})";
        "col.shadow_inactive" = "rgba(${custom.background}00)";
        blur = {
          enabled = true;
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
        vrr = false; # misc:vrr -> Adaptive sync of your monitor. 0 (off), 1 (on), 2 (fullscreen only). Default 0 to avoid white flashes on select hardware.
      };

      bind = [
        # Binds
        "SUPER,Q,killactive,"
        "SUPER,M,exit,"
        "SUPER,S,togglefloating,"
        "SUPER,g,togglegroup"
        # "SUPER,tab,changegroupactive"
        # "SUPER,P,pseudo,"

        # "SUPER,h,movefocus,l"
        # "SUPER,l,movefocus,r"
        # "SUPER,k,movefocus,u"
        # "SUPER,j,movefocus,d"

        "SUPER,left,movefocus,l"
        "SUPER,down,movefocus,r"
        "SUPER,up,movefocus,u"
        "SUPER,right,movefocus,d"

        #CTRL,1,workspace,1
        #CTRL,2,workspace,2
        #CTRL,3,workspace,3
        #CTRL,4,workspace,4
        #CTRL,5,workspace,5
        #CTRL,6,workspace,6
        "SUPER,1,workspace,1"
        "SUPER,2,workspace,2"
        "SUPER,3,workspace,3"
        "SUPER,4,workspace,4"
        "SUPER,5,workspace,5"
        "SUPER,6,workspace,6"
        "SUPER,7,workspace,7"
        "SUPER,8,workspace,8"
        # "SUPER,9,workspace,9"
        # "SUPER,0,workspace,10"
        # "SUPER,z,exec,waybar"

        ################################## Move ###########################################
        # "SUPER SHIFT, H, movewindow, l"
        # "SUPER SHIFT, L, movewindow, r"
        # "SUPER SHIFT, K, movewindow, u"
        # "SUPER SHIFT, J, movewindow, d"
        "SUPER SHIFT, left, movewindow, l"
        "SUPER SHIFT, right, movewindow, r"
        "SUPER SHIFT, up, movewindow, u"
        "SUPER SHIFT, down, movewindow, d"

        #---------------------------------------------------------------#
        # Move active window to a workspace with mainMod + ctrl + [0-9] #
        #---------------------------------------------------------------#
        # "SUPER $mainMod CTRL, 1, movetoworkspace, 1"
        # "SUPER $mainMod CTRL, 2, movetoworkspace, 2"
        # "SUPER $mainMod CTRL, 3, movetoworkspace, 3"
        # "SUPER $mainMod CTRL, 4, movetoworkspace, 4"
        # "SUPER $mainMod CTRL, 5, movetoworkspace, 5"
        # "SUPER $mainMod CTRL, 6, movetoworkspace, 6"
        # "SUPER $mainMod CTRL, 7, movetoworkspace, 7"
        # "SUPER $mainMod CTRL, 8, movetoworkspace, 8"
        # "SUPER $mainMod CTRL, 9, movetoworkspace, 9"
        # "SUPER $mainMod CTRL, 0, movetoworkspace, 10"
        # "SUPER $mainMod CTRL, left, movetoworkspace, -1"
        # "SUPER $mainMod CTRL, right, movetoworkspace, +1"
        # same as above, but doesnt switch to the workspace
        "SUPER $mainMod SHIFT, 1, movetoworkspacesilent, 1"
        "SUPER $mainMod SHIFT, 2, movetoworkspacesilent, 2"
        "SUPER $mainMod SHIFT, 3, movetoworkspacesilent, 3"
        "SUPER $mainMod SHIFT, 4, movetoworkspacesilent, 4"
        "SUPER $mainMod SHIFT, 5, movetoworkspacesilent, 5"
        "SUPER $mainMod SHIFT, 6, movetoworkspacesilent, 6"
        "SUPER $mainMod SHIFT, 7, movetoworkspacesilent, 7"
        "SUPER $mainMod SHIFT, 8, movetoworkspacesilent, 8"
        # "SUPER $mainMod SHIFT, 9, movetoworkspacesilent, 9"
        # "SUPER $mainMod SHIFT, 0, movetoworkspacesilent, 10"

        # "SUPER,n,exec,~/.local/bin/lvimn"
        # "SUPER,e,exec, emacsclient -c -a 'emacs'"
        # "SUPER,o,exec, obsidian"

        "SUPER,RETURN,exec, kitty"
        "SUPER,f,exec, firefox"
        # ",Print,exec, ~/.config/hypr/scripts/screenshot.sh"
        # "SUPER,space,exec, bemenu-run"
        # SUPER,space,exec,wofi --show drun -I -s ~/.config/wofi/style.css DP-3
        "ALT,space,exec,wofi --show drun -I DP-2"
        # "SUPER SHIFT,V,exec,~/.config/eww/fool_moon/bar/scripts/widgets toggle-clip"
        # "SUPER SHIFT,C,exec,~/.config/hypr/scripts/wallpaper_picker"
        # "SUPER $mainMod SHIFT,B,exec, killall -3 eww & sleep 1 && ~/.config/hypr/themes/winter/eww/launch_bar"

        # Tell wireplumber to toggle mute volume on mute key 
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ];

      binde = [
        # Tell wireplumber to raise/lower volume with volume keys
        ", XF86AudioLowerVolume, exec, wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+"
      ];

      bindm = [
        # Mouse binds
        # "SUPER,mouse_down,workspace,e+1"
        # "SUPER,mouse_up,workspace,e-1"
        "SUPER,mouse:272,movewindow"
        "SUPER,mouse:273,resizewindow"
      ];

      windowrule = [
        # Window rules
        "tile,title:^(kitty)$"
        "float,title:^(fly_is_kitty)$"
        "opacity 1.0 override 1.0 override,^(foot)$" # Active/inactive opacity
        "opacity 1.0 override 1.0 override,^(kitty)$" # Active/inactive opacity
        "tile,^(Spotify)$"
        "tile,^(neovide)$"
        "tile,^(wps)$"
        "opacity 1.0 override 1.0 override,^(neovide)$" # Active/inactive opacity
      ];

      windowrulev2 = [
        "opacity ${custom.opacity} ${custom.opacity},class:^(thunar)$"
        # "opacity ${custom.opacity} ${custom.opacity},class:^(WebCord)$"
        "float,class:^(pavucontrol)$"
        "float,class:^(file_progress)$"
        "float,class:^(confirm)$"
        "float,class:^(dialog)$"
        "float,class:^(download)$"
        "float,class:^(notification)$"
        "float,class:^(error)$"
        "float,class:^(confirmreset)$"
        "float,title:^(Open File)$"
        "float,title:^(Save As)$"
        "float,title:^(branchdialog)$"
        "float,title:^(Confirm to replace files)$"
        "float,title:^(File Operation Progress)$"
        "float,title:^(Picture-in-Picture)$"
        "float,title:^(mpv)$"
        "opacity 1.0 1.0,class:^(wofi)$"
        "opacity 0.0 override 0.0 override,class:^(xwaylandvideobridge)$"
        "noanim,class:^(xwaylandvideobridge)$"
        "nofocus,class:^(xwaylandvideobridge)$"
        "noinitialfocus,class:^(xwaylandvideobridge)$"
      ];
    };
  };

}
