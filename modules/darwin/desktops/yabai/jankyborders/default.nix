{config, ...}: let
  inherit (config.lib.stylix) colors;
in {
  services.jankyborders = {
    enable = true;
    active_color = "0x${colors.base0D}";
    inactive_color = "0x${colors.base03}";

    blacklist = [];
  };
}
