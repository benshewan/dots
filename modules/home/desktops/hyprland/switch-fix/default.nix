{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.wayland.windowManager.hyprland.enable {
    home.activation.runMyService = config.lib.dag.entryAfter ["writeBoundary"] ''
      echo "🔁 Starting systemd --user service: hyprlandDisplayFixer"
      ${lib.getExe' pkgs.systemd "systemctl"} --user start hyprlandDisplayFixer
    '';
    systemd.user.services.hyprlandDisplayFixer = let
      hyprlandDisplayFixer = pkgs.writeShellScript "hyprlandDisplayFixer" ''
        ${lib.concatStringsSep "\n" (lib.flatten (map (
            m: let
              resolution = "${toString m.width}x${toString m.height}@${toString m.refreshRate}";
              position = "${toString m.x}x${toString m.y}";
              scale = toString m.scale;
            in
              if m.name == "eDP-1"
              then [
                ''
                  result=$(${./check_lid.sh})

                  echo $result
                  if [ $result == "closed" ]; then
                    # Code to execute if the condition is true
                    echo "disabling"
                    ${lib.getExe' config.wayland.windowManager.hyprland.package "hyprctl"} keyword monitor '${m.name}, disable'

                  elif [ $result == "open" ]; then
                    ${lib.getExe' config.wayland.windowManager.hyprland.package "hyprctl"} keyword monitor '${m.name}, ${resolution}, ${position}, ${scale}'
                  fi
                ''
              ]
              else []
          )
          config.monitors))}
      '';
    in {
      Unit = {
        Description = "Correct the display state after a flake switch.";
        After = ["graphical-session.target"];
      };
      Service = {
        Type = "oneshot";
        ExecStart = hyprlandDisplayFixer;
      };
    };
  };
}
