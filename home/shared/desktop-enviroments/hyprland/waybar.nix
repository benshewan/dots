{ config, inputs, outputs, ... }:
let
  custom = {
    font = "RobotoMono Nerd Font";
  };
  hexToRGBString = inputs.nix-colors.lib.conversions.hexToRGBString;
  colors = config.colorScheme.colors;
in
{
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
      modules-left = [
        "custom/launcher"
        "custom/playerctl#backward"
        "custom/playerctl#play"
        "custom/playerctl#foward"
        "custom/playerlabel"
      ];
      modules-center = [
        "wlr/workspaces"
      ];
      modules-right = [
        "tray"
        "custom/headset"
        "battery"
        "pulseaudio"
        "network"
        "clock"
      ];
      clock = {
        format = " {:%a, %d %b, %I:%M %p}";
        tooltip = "true";
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        format-alt = " {:%d/%m}";
      };
      "wlr/workspaces" = {
        active-only = false;
        all-outputs = false;
        disable-scroll = false;
        on-scroll-up = "hyprctl dispatch workspace e-1";
        on-scroll-down = "hyprctl dispatch workspace e+1";
        format = "{name}";
        on-click = "activate";
        format-icons = {
          urgent = "";
          active = "";
          default = "";
          sort-by-number = true;
        };
      };
      "custom/playerctl#backward" = {
        format = "󰙣 ";
        on-click = "playerctl previous";
        on-scroll-up = "playerctl volume .05+";
        on-scroll-down = "playerctl volume .05-";
      };
      "custom/playerctl#play" = {
        format = "{icon}";
        return-type = "json";
        exec = "playerctl -a metadata --format '{\"text\": \"{{artist}} - {{markup_escape(title)}}\", \"tooltip\": \"{{playerName}} : {{markup_escape(title)}}\", \"alt\": \"{{status}}\", \"class\": \"{{status}}\"}' -F";
        on-click = "playerctl play-pause";
        on-scroll-up = "playerctl volume .05+";
        on-scroll-down = "playerctl volume .05-";
        format-icons = {
          Playing = "<span>󰏥 </span>";
          Paused = "<span> </span>";
          Stopped = "<span> </span>";
        };
      };
      "custom/playerctl#foward" = {
        format = "󰙡 ";
        on-click = "playerctl next";
        on-scroll-up = "playerctl volume .05+";
        on-scroll-down = "playerctl volume .05-";
      };
      "custom/playerlabel" = {
        format = "<span>󰎈 {} 󰎈</span>";
        return-type = "json";
        max-length = 40;
        exec = "playerctl -a metadata --format '{\"text\": \"{{artist}} - {{markup_escape(title)}}\", \"tooltip\": \"{{playerName}} : {{markup_escape(title)}}\", \"alt\": \"{{status}}\", \"class\": \"{{status}}\"}' -F";
        on-click = "";
      };
      battery = {
        states = {
          good = 95;
          warning = 30;
          critical = 15;
        };
        format = "{icon}  {capacity}%";
        format-charging = "  {capacity}%";
        format-plugged = " {capacity}% ";
        format-alt = "{icon} {time}";
        format-icons = [ "" "" "" "" "" ];
      };

      memory = {
        format = "󰍛 {}%";
        format-alt = "󰍛 {used}/{total} GiB";
        interval = 5;
      };
      cpu = {
        format = "󰻠 {usage}%";
        format-alt = "󰻠 {avg_frequency} GHz";
        interval = 5;
      };
      network = {
        format-wifi = "  {signalStrength}%";
        format-ethernet = "󰈀 100% ";
        tooltip-format = "Connected to {essid} {ifname} via {gwaddr}";
        format-linked = "{ifname} (No IP)";
        format-disconnected = "󰖪 0% ";
      };
      tray = {
        icon-size = 20;
        spacing = 8;
      };
      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "󰝟";
        format-icons = {
          default = [ "󰕿" "󰖀" "󰕾" ];
        };
        # on-scroll-up= "bash ~/.scripts/volume up";
        # on-scroll-down= "bash ~/.scripts/volume down";
        scroll-step = 5;
        on-click = "pavucontrol";
      };
      "custom/randwall" = {
        format = "󰏘";
        # on-click= "bash $HOME/.config/hypr/randwall.sh";
        # on-click-right= "bash $HOME/.config/hypr/wall.sh";
      };
      "custom/launcher" = {
        format = "";
        # on-click= "bash $HOME/.config/rofi/launcher.sh";
        # on-click-right= "bash $HOME/.config/rofi/run.sh"; 
        tooltip = "false";
      };
      "custom/headset" = {
        format = "󰋋 {}";
        interval = 5;
        exec = "${outputs.flake-path}/scripts/get_battery_headset";
      };
    };
    style = ''
      * {
          border: none;
          border-radius: 0px;
          font-family: ${custom.font};
          font-size: 14px;
          min-height: 0;
      }

      window#waybar {
          background: rgba(${hexToRGBString "," colors.base01},.85);
      }
      #workspaces {
          background: #${colors.base02};
          margin: 5px 5px;
          padding: 8px 5px;
          border-radius: 16px;
          color: #${colors.base09}
      }
      #workspaces button {
          padding: 0px 5px;
          margin: 0px 3px;
          border-radius: 16px;
          color: transparent;
          background: rgba(${hexToRGBString "," colors.base01},.85);
          transition: all 0.3s ease-in-out;
      }

      #workspaces button.active {
          background-color: #${colors.base0D};
          color: #${colors.base00};
          border-radius: 16px;
          min-width: 50px;
          background-size: 400% 400%;
          transition: all 0.3s ease-in-out;
      }

      #workspaces button:hover {
          background-color: #${colors.base05};
          color: #${colors.base00};
          border-radius: 16px;
          min-width: 50px;
          background-size: 400% 400%;
      }

      #tray, #pulseaudio, #network, #battery,
      #custom-playerctl.backward, #custom-playerctl.play, #custom-playerctl.foward, #custom-headset {
          background: #${colors.base02};
          font-weight: bold;
          margin: 5px 0px;
      }
      #tray, #pulseaudio, #network, #battery, #custom-headset {
          color: #${colors.base05};
          border-radius: 10px 24px 10px 24px;
          padding: 0 20px;
          margin-left: 7px;
      }
      #clock {
          color: #${colors.base05};
          background: #${colors.base02};
          border-radius: 0px 0px 0px 40px;
          padding: 10px 10px 15px 25px;
          margin-left: 7px;
          font-weight: bold;
          font-size: 16px;
      }
      #custom-launcher {
          color: #${colors.base0D};
          background: #${colors.base02};
          border-radius: 0px 0px 40px 0px;
          margin: 0px;
          padding: 0px 35px 0px 15px;
          font-size: 28px;
      }

      #custom-playerctl.backward, #custom-playerctl.play, #custom-playerctl.foward {
          background: #${colors.base02};
          font-size: 22px;
      }
      #custom-playerctl.backward:hover, #custom-playerctl.play:hover, #custom-playerctl.foward:hover{
          color: #${colors.base01};
      }
      #custom-playerctl.backward {
          color: #${colors.base0E};
          border-radius: 24px 0px 0px 10px;
          padding-left: 16px;
          margin-left: 7px;
      }
      #custom-playerctl.play {
          color: #${colors.base0D};
          padding: 0 5px;
      }
      #custom-playerctl.foward {
          color: #${colors.base0E};
          border-radius: 0px 10px 24px 0px;
          padding-right: 12px;
          margin-right: 7px
      }
      #custom-playerlabel {
          background: #${colors.base02};
          color: #${colors.base05};
          padding: 0 20px;
          border-radius: 24px 10px 24px 10px;
          margin: 5px 0;
          font-weight: bold;
      }
      #window{
          background: #${colors.base02};
          padding-left: 15px;
          padding-right: 15px;
          border-radius: 16px;
          margin-top: 5px;
          margin-bottom: 5px;
          font-weight: normal;
          font-style: normal;
      }
    '';
  };
}
