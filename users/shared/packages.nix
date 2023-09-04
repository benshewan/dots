{ pkgs, inputs, username, ... }:
{

  # Default application configuration
  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "text/html" = "firefox.desktop";
    "x-scheme-handler/mongodb" = "mongodb-compass.desktop";
    "x-scheme-handler/mongodb+srv" = "mongodb-compass.desktop";
    "x-scheme-handler/insomnia" = "insomnia.desktop";
  };

  # Fonts
  fonts.fontconfig.enable = true;



  #Packages
  home.packages = with pkgs; [
    # speedtest-cli
    # gcc
    # (nerdfonts.override { fonts = [ "RobotoMono" ]; })
  ];

  programs.git = {
    enable = true;
    userName = "benshewan";
    userEmail = "benbshewan@gmail.com";
  };
}
