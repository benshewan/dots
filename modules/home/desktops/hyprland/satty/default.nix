{
  config,
  lib,
  pkgs,
  ...
}: let
  tomlFormat = pkgs.formats.toml {};
  configFileName = "config.toml";
in {
  config = lib.mkIf config.night-sky.desktops.hyprland.enable {
    xdg.configFile."satty/${configFileName}".source =
      tomlFormat.generate configFileName
      {
        general = {
          fullscreen = true;
          early-exit = true;
          corner-roundness = 2;
          initial-tool = "rectangle";
          copy-command = lib.getExe' pkgs.wl-clipboard "wl-copy";
          annotation-size-factor = 1;
          output-filename = "/tmp/test-%Y-%m-%d_%H:%M:%S.png";
          save-after-copy = false;
          default-hide-toolbars = false;
          primary-highlighter = "block";
          disable-notifications = false;
          actions-on-right-click = [];
          # [possible values: save-to-clipboard, save-to-file, exit]
          actions-on-enter = ["save-to-clipboard"];
          # Actions to trigger on Escape key (order is important)
          # [possible values: save-to-clipboard, save-to-file, exit]
          actions-on-escape = ["exit"];
          # request no window decoration. Please note that the compositor has the final say in this. At this point. requires xdg-decoration-unstable-v1.
          no-window-decoration = true;
          # experimental feature: adjust history size for brush input smoothing (0: disabled, default: 0, try e.g. 5 or 10)
          brush-smooth-history-size = 10;
        };
        font.family = config.stylix.fonts.sansSerif.name;
        font.style = "Bold";

        color-palette = {
          # These will be shown in the toolbar for quick selection
          palette = [
            "#00ffff"
            "#a52a2a"
            "#dc143c"
            "#ff1493"
            "#ffd700"
            "#008000"
          ];

          # These will be available in the color picker as presets
          # Leave empty to use GTK's default
          custom = [
            "#00ffff"
            "#a52a2a"
            "#dc143c"
            "#ff1493"
            "#ffd700"
            "#008000"
          ];
        };
      };
  };
}
