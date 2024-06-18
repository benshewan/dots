{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) types mkIf mkDefault mkMerge;
  inherit (lib.night-sky) mkOpt;
  colors = config.lib.stylix.colors.withHashtag;
  cfg = config.night-sky.programs.rofi;

  # theme collection
  rofi-themes = pkgs.fetchFromGitHub {
    owner = "adi1090x";
    repo = "rofi";
    rev = "a3c2def145e354d3cb88fafbbccfe8bd37da88db";
    sha256 = "sha256-Ew3Po2y20OlOtiX08A4ySxvdLC9KTrNQd32SQZz6DJM=";
  };
in {
  options.night-sky.programs.rofi = {
    enable = lib.mkEnableOption "rofi";
    launcher = {
      type = mkOpt types.int 1 "the type of launcher";
      style = mkOpt types.int 1 "the style of launcher";
      command =
        mkOpt types.str
        "${lib.getExe' config.programs.rofi.package "rofi"} -show drun -theme $HOME/.config/rofi/launcher.rasi"
        "The command used to launch rofi app launcher";
    };

    clipboard = {
      type = mkOpt types.int 4 "the type of clipboard";
      style = mkOpt types.int 2 "the style of clipboard";
      command =
        mkOpt types.str
        ''${./cliphist-rofi-img.sh} | ${lib.getExe' config.programs.rofi.package "rofi"} -dmenu -p "clipboard" -theme $HOME/.config/rofi/clipboard.rasi | ${lib.getExe pkgs.cliphist} decode | wl-copy''
        "The command used to launch rofi clipboard";
    };
  };

  config = lib.mkIf config.night-sky.desktops.hyprland.enable {
    # Install rofi themes
    home.file.".config/rofi/launcher.rasi".source = "${rofi-themes}/files/launchers/type-${toString cfg.launcher.type}/style-${toString cfg.launcher.style}.rasi";
    home.file.".config/rofi/clipboard.rasi".source = "${rofi-themes}/files/launchers/type-${toString cfg.clipboard.type}/style-${toString cfg.clipboard.style}.rasi";

    home.file.".config/rofi/shared/fonts.rasi".text = ''
      * {
      font: "${config.stylix.fonts.sansSerif.name} ${toString config.stylix.fonts.sizes.desktop}";
      }'';
    home.file.".config/rofi/shared/colors.rasi".text = ''        
      * {
          background:     ${colors.base01};
          background-alt: ${colors.base00};
          foreground:     ${colors.base05};
          selected:       ${colors.base0D};
          active:         ${colors.base0F};
          urgent:         ${colors.base0E};
      }'';

    home.packages = with pkgs; [
      rofi-bluetooth
    ];

    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      location = "center";
      terminal = lib.getExe pkgs.kitty;

      plugins = with pkgs; [
        rofi-calc
        rofi-power-menu
      ];
    };
  };
}
