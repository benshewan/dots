{ 
    # custom ? {
    #     font = "RobotoMono Nerd Font";
    #     primary_accent = "cba6f7";
    #     secondary_accent = "89b4fa";
    #     tertiary_accent = "f5f5f5";
    #     background = "11111B";
    #     opacity = "1";
    # },
    ... 
}:
let
  custom = rec {
    font = "RobotoMono Nerd Font";
    fontsize = "12";
    primary_accent = "cba6f7";
    secondary_accent = "89b4fa";
    tertiary_accent = "f5f5f5";
    background = "11111B";
    opacity = ".85";
    cursor = "Numix-Cursor";
    palette = {
      font = "RobotoMono Nerd Font";
      fontsize = "12";
      primary_accent = "cba6f7";
      secondary_accent = "89b4fa";
      tertiary_accent = "f5f5f5";
      background = "11111B";
      opacity = ".85";
      cursor = "Numix-Cursor";
      palette = {
        primary_accent_hex = "cba6f7";
        secondary_accent_hex = "89b4fa";
        tertiary_accent_hex = "f5f5f5";
        primary_background_hex = "11111B";
        secondary_background_hex = "1b1b2b";
        tertiary_background_hex = "25253a";
        primary_accent_rgba = "rgba(203,166,247,${opacity})";
        secondary_accent_rgba = "rgba(137,180,250,${opacity})";
        tertiary_accent_rgba = "rgba(245,245,245,${opacity})";
        primary_background_rgba = "rgba(17,17,27,${opacity})";
        secondary_background_rgba = "rgba(27,27,43,${opacity})";
        tertiary_background_rgba = "rgba(37,37,58,${opacity})";

        opacity = ".85";
      };
    };
  };
in
{
    programs.wofi = {
        enable = true;
        settings = {
            allow_images = true;
            width = "25%";
            hide_scroll = true;
            term = "kitty";
        };
        style =''
        * {
          font-family: ${custom.font},monospace;
          font-weight: bold;
        }
        #window {
          border-radius: 40px;
          background: rgba(17,17,27,.85)
        }
        #input {
          border-radius: 100px;
          margin: 20px;
          padding: 15px 25px;
          background: rgba(37,37,58,.85);
          color: #${custom.tertiary_accent};
        }
        #outer-box {
          font-weight: bold;
          font-size: 14px;
        }
        #entry {
          margin: 10px 80px;
          padding: 20px 20px;
          border-radius: 200px;
        }
        #entry:selected{
          background-color:#${custom.primary_accent};
          color: #${custom.background};
        }
        #entry:hover {
        }
        '';
    };
}