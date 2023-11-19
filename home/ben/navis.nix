{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./global
    ../shared/desktop-enviroments/hyprland
  ];

  monitors = [
    # Internal Monitor
    {
      name = "eDP-1";
      width = 2256;
      height = 1504;
      refreshRate = 60;
      workspace = "1";
      primary = true;
      scale = 1.25;
      x = 0;
      y = 0;
    }
    # Work Monitors - x/y postion not working right with the internal monitor
    {
      name = "desc:Dell Inc. DELL P2417H KH0NG94M1NNB";
      width = 1920;
      height = 1080;
      refreshRate = 60;
      workspace = "2";
      scale = 1.0;
      x = 903;
      y = -1203;
    }
    {
      name = "desc:Dell Inc. DELL P2417H KH0NG95F09UI";
      width = 1920;
      height = 1080;
      refreshRate = 60;
      workspace = "3";
      scale = 1.0;
      x = 2823;
      y = -1203;
    }

    # Home Monitors
    {
      name = "desc:Samsung Electric Company C27F390 HTQK900407";
      width = 1920;
      height = 1080;
      refreshRate = 60;
      workspace = "4";
      scale = 1.0;
      x = 0;
      y = -1080;
    }
  ];

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
    ];
  };
}
