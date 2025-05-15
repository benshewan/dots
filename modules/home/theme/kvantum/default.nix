{
  pkgs,
  config,
  lib,
  ...
}: {
  options.stylix.targets.kvantum = {
    enable = config.lib.stylix.mkEnableTarget "Kvantum" pkgs.stdenv.hostPlatform.isLinux;
    iconThemeName = lib.mkOption {
      description = "Default QT Icons";
      type = lib.types.str;
      default = "Papirus-Dark";
    };
  };

  config = lib.mkIf (config.stylix.targets.kvantum.enable && !config.night-sky.desktops.kde.enable) (let
    cfg = config.stylix.targets.kvantum;

    kvconfig = config.lib.stylix.colors {
      template = ./kvconfig.mustache;
      extension = ".kvconfig";
    };
    svg = config.lib.stylix.colors {
      template = ./kvantum-svg.mustache;
      extension = "svg";
    };
    kvantumPackage = pkgs.runCommandLocal "base16-kvantum" {} ''
      mkdir -p $out/share/Kvantum/Base16Kvantum
      cat ${kvconfig} >>$out/share/Kvantum/Base16Kvantum/Base16Kvantum.kvconfig
      cat ${svg} >>$out/share/Kvantum/Base16Kvantum/Base16Kvantum.svg
    '';
  in {
    home.packages = with pkgs; [
      libsForQt5.qt5ct
      libsForQt5.qtstyleplugin-kvantum
      qt6Packages.qtstyleplugin-kvantum
      kvantumPackage
      papirus-icon-theme
    ];

    stylix.targets.qt.enable = lib.mkForce false;

    qt = {
      enable = true;
      platformTheme.name = "qtct";
    };

    xdg.configFile."Kvantum/kvantum.kvconfig".source = (pkgs.formats.ini {}).generate "kvantum.kvconfig" {
      General.theme = "Base16Kvantum";
    };
    xdg.configFile."Kvantum/Base16Kvantum".source = "${kvantumPackage}/share/Kvantum/Base16Kvantum";

    xdg.configFile."qt5ct/qt5ct.conf".text = ''
      [Appearance]
      style=kvantum
      icon_theme=${cfg.iconThemeName}
    '';

    xdg.configFile."qt6ct/qt6ct.conf".text = ''
      [Appearance]
      style=kvantum
      icon_theme=${cfg.iconThemeName}
    '';
  });
}
