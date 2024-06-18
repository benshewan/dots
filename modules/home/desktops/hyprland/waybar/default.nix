{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.night-sky.desktops.hyprland.enable {
    programs.waybar = {
      enable = true;
      settings.mainBar = {
        position = "top";
        layer = "top";
        height = 35;
        margin-top = 0;
        margin-bottom = 0;
        margin-left = 0;
        margin-right = 0;

        # Layout
        modules-left = [
          "hyprland/workspaces"
        ];
        modules-center = [
          "clock"
        ];
        modules-right = [
          "tray"
          "bluetooth"
          "battery"
          "pulseaudio"
        ];

        # Clock
        clock = {
          format = "{:%I:%M %p} ";
          tooltip = true;
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          format-alt = " {:%d/%m}";
        };

        # Workspaces
        "hyprland/workspaces" = {
          active-only = false;
          all-outputs = false;
          disable-scroll = true;
          # persistent-workspaces = {
          #   "*" = 8;
          # };
          format = "{}";
          on-click = "activate";
          format-icons = {
            urgent = "";
            active = "";
            default = "";
            sort-by-number = true;
          };
        };

        # Media Controls
        "custom/playerlabel" = {
          format = "<span>󰎈 {} 󰎈</span>";
          return-type = "json";
          max-length = 40;
          exec = "playerctl -a metadata --format '{\"text\": \"{{artist}} - {{markup_escape(title)}}\", \"tooltip\": \"{{playerName}} : {{markup_escape(title)}}\", \"alt\": \"{{status}}\", \"class\": \"{{status}}\"}' -F";
          on-click = "";
        };

        # Battery
        battery = {
          states = {
            good = 95;
            warning = 30;
            critical = 15;
          };
          format = "{icon}  {capacity}%";
          format-charging = "  {capacity}%";
          format-plugged = "  {capacity}% ";
          format-alt = "{icon}  {time}";
          format-icons = ["" "" "" "" ""];
        };

        # Wifi/Ethernet
        network = {
          format-wifi = "  {signalStrength}%";
          format-ethernet = "󰈀 100% ";
          tooltip-format = "Connected to {essid} {ifname} via {gwaddr}";
          format-linked = "{ifname} (No IP)";
          format-disconnected = "󰖪 0% ";
        };

        # System Tray
        tray = {
          show-passive-items = true;
          icon-size = 20;
          spacing = 8;
        };

        # Audio
        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = " 󰝟 ";
          format-icons = {
            default = ["󰕿" "󰖀" "󰕾"];
          };
          # on-scroll-up= "bash ~/.scripts/volume up";
          # on-scroll-down= "bash ~/.scripts/volume down";
          scroll-step = 5;
          on-click = "pavucontrol";
        };

        # Bluetooth
        bluetooth = {
          on-click = ./togglebluetooth.sh;
          format-device-preference = [
            "headset_dev_38_18_4C_95_4F_0D"
          ];
          format-connected = "󰂰";
          format-on = "";
          format-disabled = "󰂲";
          format-off = "󰂲";
          tooltip-format = "{num_connections} connected";
          tooltip-format-connected = "{num_connections} connected\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}";
          tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_battery_percentage}%";
        };
      };
      style = lib.readFile ./waybar.css;
    };
  };
}
