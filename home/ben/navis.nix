{pkgs, ...}: {
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
      workspace = "1";
      primary = true;
      scale = 1.5;
    }

    # Work Monitors
    {
      name = "desc:Dell Inc. DELL P2417H KH0NG94M1NNB";
      width = 1920;
      height = 1080;
      workspace = "2";
      x = -1017;
      y = -1080;
    }
    {
      name = "desc:Dell Inc. DELL P2417H KH0NG95F09UI";
      width = 1920;
      height = 1080;
      workspace = "3";
      x = 903;
      y = -1080;
    }

    # Home Monitors
    {
      name = "desc:Samsung Electric Company C27F390 HTQK900407";
      width = 1920;
      height = 1080;
      workspace = "3";
      # rotate = 1;
      x = -1920;
      y = -1080;
    }
    {
      name = "desc:Dell Inc. AW3423DWF 58082S3";
      width = 3440;
      height = 1440;
      refreshRate = 165;
      workspace = "2";
      scale = 1.25;
      x = 0;
      y = -1440;
    }
  ];

  home.packages = with pkgs; [
    prismlauncher
    distrobox
    teamviewer
    (vivaldi.override {
      enableWidevine = true;
      proprietaryCodecs = true;
    })
  ];

  services.flatpak.packages = [
    # "flathub:org.yuzu_emu.yuzu//stable"
    # "flathub:io.github.Foldex.AdwSteamGtk//stable" # Doesn't seem to quite work, steam will freak out
    "flathub:app/com.parsecgaming.parsec//stable"
    "flathub:app/com.mongodb.Compass//stable"
    # "flathub:app/com.github.tchx84.Flatseal//stable"
  ];

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
    ];
  };
}
