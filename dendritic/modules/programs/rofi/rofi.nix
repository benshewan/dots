{...} @ flake: {
  flake.modules.homeManager."programs/rofi" = {
    pkgs,
    lib,
    config,
    ...
  }: let
    inherit (lib) types;
    inherit (flake.config.flake.lib) mkOpt;
    colors = config.lib.stylix.colors.withHashtag;
    cfg = config.programs.rofi;

    # theme collection
    rofi-themes = pkgs.fetchFromGitHub {
      owner = "adi1090x";
      repo = "rofi";
      rev = "a3c2def145e354d3cb88fafbbccfe8bd37da88db";
      sha256 = "sha256-Ew3Po2y20OlOtiX08A4ySxvdLC9KTrNQd32SQZz6DJM=";
    };

    cliphist-script = pkgs.writeShellApplication "cliphist-script" ''
      tmp_dir="/tmp/cliphist"
      ${lib.getExe' pkgs.coreutils "rm"} -rf "''$tmp_dir"

      if [[ -n "''$1" ]]; then
          ${lib.getExe pkgs.cliphist} decode <<<"''$1" | ${lib.getExe' pkgs.wl-clipboard "wl-copy"}
          exit
      fi

      ${lib.getExe' pkgs.coreutils "mkdir"} -p "''$tmp_dir"

      read -r -d "" prog <<EOF
      /^[0-9]+\s<meta http-equiv=/ { next }
      match(\$0, /^([0-9]+)\s(\[\[\s)?binary.*(jpg|jpeg|png|bmp)/, grp) {
          system("echo " grp[1] "\\\\\t | ${lib.getExe pkgs.cliphist} decode >''$tmp_dir/"grp[1]"."grp[3])
          print \$0"\0icon\x1f''$tmp_dir/"grp[1]"."grp[3]
          next
      }
      1
      EOF

      ${lib.getExe pkgs.cliphist} list | ${lib.getExe pkgs.gawk} "''$prog"
    '';
  in {
    options.programs.rofi = {
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
          ''${cliphist-script} | ${lib.getExe' config.programs.rofi.package "rofi"} -dmenu -show-icons -i -display-columns 2 -p "clipboard" -theme $HOME/.config/rofi/clipboard.rasi | ${lib.getExe pkgs.cliphist} decode | wl-copy''
          "The command used to launch rofi clipboard";
      };
    };
    config = {
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

      programs.rofi = {
        enable = true;
        package = pkgs.rofi;
        location = "center";
        terminal = lib.getExe pkgs.kitty;
      };
    };
  };
}
