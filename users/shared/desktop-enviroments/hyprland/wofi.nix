{ config, inputs, ... }:
let
  custom = {
    font = "RobotoMono Nerd Font";
  };
in
{
  programs.wofi = {
    enable = true;
    settings = {
      allow_images = true;
      width = "33%";
      hide_scroll = true;
      term = "kitty";
    };
    style = ''
      * {
        font-family: ${custom.font},monospace;
        font-weight: bold;
      }
      #window {
        border-radius: 40px;
        background: rgba(${inputs.nix-colors.lib.conversions.hexToRGBString "," config.colorScheme.colors.base01},.85);
      }
      #input {
        border-radius: 100px;
        margin: 10px;
        padding: 5px 15px;
        background:rgba(${inputs.nix-colors.lib.conversions.hexToRGBString "," config.colorScheme.colors.base00},1);
        color: #${config.colorScheme.colors.base05};
      }
      #outer-box {
        font-weight: bold;
        font-size: 14px;
      }
      #entry {
        margin: 10px 80px;
        padding: 10px;
        border-radius: 200px;
      }
      #entry:selected{
        background-color:#${config.colorScheme.colors.base0D};
        color: #${config.colorScheme.colors.base01};
      }
      #entry:hover {
      }
    '';
  };
}
