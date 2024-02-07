{
  pkgs,
  outputs,
  ...
}: {
  imports = [
    ./generic.nix
    "${outputs.flake-path}/shared/hm/desktops/hyprland"
    "${outputs.flake-path}/themes/gruvbox/hm"
  ];

  monitors = [
    # Internal Monitor
    {
      name = "eDP-1";
      width = 2256;
      height = 1504;
      primary = true;
      scale = 1.566667;
    }

    # Work Monitors
    {
      name = "desc:Dell Inc. DELL P2417H KH0NG94M1NNB";
      width = 1920;
      height = 1080;
      x = -1017;
      y = -1080;
    }
    {
      name = "desc:Dell Inc. DELL P2417H KH0NG95F09UI";
      width = 1920;
      height = 1080;
      x = 903;
      y = -1080;
    }

    # Home Monitors
    {
      name = "desc:Samsung Electric Company C27F390 HTQK900407";
      rotate = 1;
      width = 1920;
      height = 1080;
      x = -1080;
      y = -1920;
    }
    {
      name = "desc:Dell Inc. AW3423DWF 58082S3";
      width = 3440;
      height = 1440;
      refreshRate = 165;
      scale = 1.25;
      x = 0;
      y = -1152;
    }
  ];

  home.packages = with pkgs; [
    prismlauncher
    distrobox

    # Work stuff
    teamviewer
    masterpdfeditor
    wisenet-viewer
    stable.moonlight-qt
    inkscape

    # Messing around
    goldwarden # a lightweight daemon to add functionallity missing from the native bitwarden client
  ];

  services.flatpak.packages = [
    # "flathub:app/io.github.Foldex.AdwSteamGtk//stable" # Doesn't seem to quite work, steam will freak out
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
