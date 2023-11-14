{
  config,
  lib,
  pkgs,
  ...
}: {
  wayland.windowManager.hyprland.settings = {
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

      "SUPER,1,workspace,1"
      "SUPER,2,workspace,2"
      "SUPER,3,workspace,3"
      "SUPER,4,workspace,4"
      "SUPER,5,workspace,5"
      "SUPER,6,workspace,6"
      "SUPER,7,workspace,7"
      "SUPER,8,workspace,8"

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
      "SUPER SHIFT, 1, movetoworkspacesilent, 1"
      "SUPER SHIFT, 2, movetoworkspacesilent, 2"
      "SUPER SHIFT, 3, movetoworkspacesilent, 3"
      "SUPER SHIFT, 4, movetoworkspacesilent, 4"
      "SUPER SHIFT, 5, movetoworkspacesilent, 5"
      "SUPER SHIFT, 6, movetoworkspacesilent, 6"
      "SUPER SHIFT, 7, movetoworkspacesilent, 7"
      "SUPER SHIFT, 8, movetoworkspacesilent, 8"
      "SUPER SHIFT, 9, movetoworkspacesilent, 9"
      "SUPER SHIFT, 0, movetoworkspacesilent, 10"

      # "SUPER,n,exec,~/.local/bin/lvimn"
      # "SUPER,e,exec, emacsclient -c -a 'emacs'"
      # "SUPER,o,exec, obsidian"

      # Color Picker
      "SUPER SHIFT,c,exec,${lib.getExe' pkgs.hyprpicker "hyprpicker"} -a -f hex"

      # Program Keybinds
      "SUPER,RETURN,exec, kitty"
      "SUPER,f,exec, firefox"

      # Rofi keybinds
      "ALT,space,exec,${lib.getExe' config.programs.rofi.package "rofi"} -show drun"
      "SUPER,v,exec,${lib.getExe pkgs.cliphist} list | ${lib.getExe' config.programs.rofi.package "rofi"} -dmenu | ${lib.getExe pkgs.cliphist} decode | wl-copy"

      # Screenshot keybinds
      "SUPER, s, exec, ${lib.getExe pkgs.grimblast} --notify copy area"
      "SUPER SHIFT, s, exec, ${lib.getExe pkgs.grimblast} --notify copy output"

      # "SUPER SHIFT,V,exec,~/.config/eww/fool_moon/bar/scripts/widgets toggle-clip"
      # "SUPER SHIFT,C,exec,~/.config/hypr/scripts/wallpaper_picker"
      # "SUPER $mainMod SHIFT,B,exec, killall -3 eww & sleep 1 && ~/.config/hypr/themes/winter/eww/launch_bar"
    ];

    # Repeat if held
    binde = [
      # Tell wireplumber to raise/lower volume with volume keys
      ", XF86AudioLowerVolume, exec, ${dunst/volume_brightness.sh} volume_down"
      ", XF86AudioRaiseVolume, exec, ${dunst/volume_brightness.sh} volume_up"

      # Control display brightness
      ",XF86MonBrightnessUp, exec, ${dunst/volume_brightness.sh} brightness_up"
      ",XF86MonBrightnessDown, exec, ${dunst/volume_brightness.sh} brightness_down"
    ];

    # Run even when screen locked
    bindl =
      [
        # Set Mutli Media Keys
        ", XF86AudioMute, exec, ${dunst/volume_brightness.sh} volume_mute"
        ", XF86AudioPlay, exec, playerctl ${dunst/volume_brightness.sh} play_pause"
        ", XF86AudioNext, exec, ${dunst/volume_brightness.sh} next_track"
        ", XF86AudioPrev, exec, ${dunst/volume_brightness.sh} prev_track"

        # Lock screen
        "SUPER,l,exec,${lib.getExe config.programs.swaylock.package} -f"
      ]
      ++ lib.flatten (map (
          m: let
            resolution = "${toString m.width}x${toString m.height}@${toString m.refreshRate}";
            position = "${toString m.x}x${toString m.y}";
            scale = toString m.scale;
          in
            if m.name == "eDP-1"
            then [
              # ",switch:Lid Switch,exec,${lib.getExe config.programs.swaylock.package} -f" # depricated - now handled by swayidle
              # Tell laptop screen to turn off if lid is closed
              # This should only run if more than one monitor is connected
              ", switch:off:Lid Switch,exec,hyprctl keyword monitor '${m.name}, ${resolution}, ${position}, ${scale}'"
              ", switch:on:Lid Switch,exec,hyprctl keyword monitor '${m.name}, disable'"
            ]
            else []
        )
        config.monitors);

    # Bind Mouse Events
    bindm = [
      # Mouse binds
      # "SUPER,mouse_down,workspace,e+1"
      # "SUPER,mouse_up,workspace,e-1"
      "SUPER,mouse:272,movewindow"
      "SUPER,mouse:273,resizewindow"
    ];
  };
}
