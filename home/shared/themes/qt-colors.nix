{config, ...}: let
  colors = config.colorScheme.colors;
in ''
   [ColorScheme]
  active_colors=${colors.base05}, ${colors.base00}, #ff979797, #ff5e5c5b, #ff302f2e, #ff4a4947, ${colors.base05}, ${colors.base05}, ${colors.base05}, ${colors.base00}, ${colors.base00}, ${colors.base05}, #ff302f2e, ${colors.base05}, ${colors.base0D}, #ffa70b06, ${colors.base03}, #ffffffff, #ff0a0a0a, #ffffffff, #80b0b0b0
  disabled_colors=#ff808080, ${colors.base00}, #ff979797, #ff5e5c5b, #ff302f2e, #ff4a4947, #ff808080, #ff808080, #ff808080, ${colors.base01}, ${colors.base01}, ${colors.base05}, ${colors.base01}, #ff808080, ${colors.base0D}, #ffa70b06, ${colors.base03}, #ffffffff, #ff0a0a0a, #ffffffff, #80b0b0b0
  inactive_colors=${colors.base05}, ${colors.base00}, #ff979797, #ff5e5c5b, #ff302f2e, #ff4a4947, ${colors.base05}, ${colors.base05}, ${colors.base05}, ${colors.base00}, ${colors.base00}, ${colors.base05}, #ff302f2e, ${colors.base05}, ${colors.base0D}, #ffa70b06, ${colors.base03}, #ffffffff, #ff0a0a0a, #ffffffff, #80b0b0b0
''
