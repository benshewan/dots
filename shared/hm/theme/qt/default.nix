{
  config,
  pkgs,
  ...
}: {
  # Taken from https://github.com/danth/stylix/issues/51 - Casul51
  stylix.targets.kde.enable = false;
  home.file = {
    ".config/qt5ct/colors/oomox-current.conf".source = config.lib.stylix.colors {
      template = builtins.readFile ./oomox-current.conf.mustache;
      extension = ".conf";
    };
    ".config/Trolltech.conf".source = config.lib.stylix.colors {
      template = builtins.readFile ./Trolltech.conf.mustache;
      extension = ".conf";
    };
    ".config/kdeglobals".source = config.lib.stylix.colors {
      template = builtins.readFile ./Trolltech.conf.mustache;
      extension = "";
    };
    ".config/qt5ct/qt5ct.conf".text = pkgs.lib.mkBefore (builtins.readFile ./qt5ct.conf);
  };
  home.packages = with pkgs; [
    qt5ct
    papirus-icon-theme
    pkgs.libsForQt5.breeze-qt5
  ];
  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt5ct";
  };
  qt = {
    enable = true;
    style.package = pkgs.libsForQt5.breeze-qt5;
    style.name = "breeze-dark";
  };
}
