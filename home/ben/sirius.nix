{
  outputs,
  pkgs,
  lib,
  ...
}: {
  imports = [./global ../shared/desktop-enviroments/hyprland];

  monitors = [
    {
      name = "DP-2";
      width = 1920;
      height = 1080;
      refreshRate = 75;
      workspace = "1";
      x = 1920;
      primary = true;
    }
    {
      name = "HDMI-A-2";
      width = 1920;
      height = 1080;
      refreshRate = 75;
      workspace = "2";
      x = 0;
    }
  ];

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
    ];
  };
}
