{
  pkgs,
  config,
  lib,
  inputs,
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
  imports = [inputs.kvlibadwaita.homeManagerModule];
  config = lib.mkIf (config.stylix.targets.kvantum.enable && !config.night-sky.desktops.kde.enable) (let
    cfg = config.stylix.targets.kvantum;

    qtctConfig = ''
      [Appearance]
      style=kvantum
      icon_theme=${cfg.iconThemeName}
    '';
  in {
    home.packages = with pkgs; [
      libsForQt5.qt5ct
      libsForQt5.qtstyleplugin-kvantum
      qt6Packages.qtstyleplugin-kvantum
      papirus-icon-theme
    ];

    stylix.targets.qt.enable = lib.mkForce false;

    qt = {
      enable = true;
      platformTheme.name = "qtct";
      kvlibadwaita = {
        enable = true;
        auto = true;
        theme = "custom";
        base16-scheme-path = config.stylix.generated.fileTree."stylix/palette.json".source;
      };
    };

    xdg.configFile."qt5ct/qt5ct.conf".text = qtctConfig;
    xdg.configFile."qt6ct/qt6ct.conf".text = qtctConfig;
  });
}
