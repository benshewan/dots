{config, ...}: let
  colors = config.lib.stylix.colors;
in ''
   [ColorScheme]
  active_colors=#ff${colors.base05}, #ff${colors.base00}, #ff979797, #ff5e5c5b, #ff${colors.base03}, #ff4a4947, #ff${colors.base05}, #ff${colors.base05}, #ff${colors.base05}, #ff${colors.base00}, #ff${colors.base00}, #ff${colors.base05}, #ff${colors.base03}, #ff${colors.base05}, #ff${colors.base0D}, #ffa70b06, #ff${colors.base03}, #ffffffff, #ff0a0a0a, #ffffffff, #80b0b0b0
  disabled_colors=#ff808080, #ff${colors.base00}, #ff979797, #ff5e5c5b, #ff${colors.base03}, #ff4a4947, #ff808080, #ff808080, #ff808080, #ff${colors.base01}, #ff${colors.base01}, #ff${colors.base05}, #ff${colors.base01}, #ff808080, #ff${colors.base0D}, #ffa70b06, #ff${colors.base03}, #ffffffff, #ff0a0a0a, #ffffffff, #80b0b0b0
  inactive_colors=#ff${colors.base05}, #ff${colors.base00}, #ff979797, #ff5e5c5b, #ff${colors.base03}, #ff4a4947, #ff${colors.base05}, #ff${colors.base05}, #ff${colors.base05}, #ff${colors.base00}, #ff${colors.base00}, #ff${colors.base05}, #ff${colors.base03}, #ff${colors.base05}, #ff${colors.base0D}, #ffa70b06, #ff${colors.base03}, #ffffffff, #ff0a0a0a, #ffffffff, #80b0b0b0
''
