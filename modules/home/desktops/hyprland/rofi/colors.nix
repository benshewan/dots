{config, ...}: let
  colors = config.lib.stylix.colors.withHashtag;
in ''  
  * {
      background:     ${colors.base01};
      background-alt: ${colors.base00};
      foreground:     #D9E0EEFF;
      selected:       ${colors.base0D};
      active:         ${colors.base0F};
      urgent:         ${colors.base0E};
  }''
