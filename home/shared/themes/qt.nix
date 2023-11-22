{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [qt5ct lightly-qt papirus-icon-theme];

  qt = {
    enable = true;
    platformTheme = "qtct";
  };
  home.file.".config/qt5ct/qt5ct.conf".text = builtins.readFile ./qt5ct.conf;
  home.file.".config/qt5ct/colors/base-16.conf".text = import ./qt-colors.nix {inherit config;};
}
