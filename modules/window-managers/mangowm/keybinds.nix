{...}: {
  flake.modules.homeManager."window-managers/mangowm" = {
    pkgs,
    lib,
    config,
    ...
  }: {
    wayland.windowManager.mango.settings = {
      bind =
        # Standard navigation
        (map (i: "SUPER,${toString i},view,${toString i}") ((lib.range 1 9) ++ [0])) # switch to different tag
        ++ (map (i: "SUPER+SHIFT,${toString i},tagsilent,${toString i}") ((lib.range 1 9) ++ [0])) # move window to different tag
        ++ (map (i: "SUPER+SHIFT,${i},tagmon,${i}") ["up" "down" "left" "right"]) # move window to different monitor
        ++ (map (i: "SUPER,${i},focusdir,${i}") ["up" "down" "left" "right"]) # move mouse in different direction
        ++ (map (i: "SUPER+ALT,${i},focusmon,${i}") ["up" "down" "left" "right"]) # move mouse to different monitor
        ++ [
          "SUPER,Q,killclient"
          "SUPER,M,quit"
          "SUPER,F,togglefloating"
          "SUPER+SHIFT,F,togglefullscreen"
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
    };
  };
}
