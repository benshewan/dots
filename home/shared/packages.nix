{ pkgs, ... }:
{

  # Default application configuration
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Browser
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "text/html" = "firefox.desktop";
      # Mongodb
      "x-scheme-handler/mongodb" = "mongodb-compass.desktop";
      "x-scheme-handler/mongodb+srv" = "mongodb-compass.desktop";
      # Insomnia
      "x-scheme-handler/insomnia" = "insomnia.desktop";
      # Remina
      "x-scheme-handler/rdp" = "org.remmina.Remmina.desktop";
      "x-scheme-handler/spice" = "org.remmina.Remmina.desktop";
      "x-scheme-handler/vnc" = "org.remmina.Remmina.desktop";
      "x-scheme-handler/remmina" = "org.remmina.Remmina.desktop";
      "application/x-remmina" = "org.remmina.Remmina.desktop";
      # Email
      "x-scheme-handler/mailto" = "userapp-Thunderbird-CAHXA2.desktop";
      "message/rfc822" = "userapp-Thunderbird-CAHXA2.desktop";
      "x-scheme-handler/mid" = "userapp-Thunderbird-CAHXA2.desktop";
      "x-scheme-handler/webcal" = "userapp-Thunderbird-UQYXA2.desktop";
      "text/calendar" = "userapp-Thunderbird-UQYXA2.desktop";
      "application/x-extension-ics" = "userapp-Thunderbird-UQYXA2.desktop";
      "x-scheme-handler/webcals" = "userapp-Thunderbird-UQYXA2.desktop";
    };
  };

  # Fonts
  fonts.fontconfig.enable = true;



  #Packages
  home.packages = with pkgs; [
    bottles
    # speedtest-cli
    # gcc
    # (nerdfonts.override { fonts = [ "RobotoMono" ]; })
  ];

  programs.git = {
    enable = true;
    userName = "benshewan";
    userEmail = "benbshewan@gmail.com";
    extraConfig = {
      pull.rebase = false;
    };
  };
}
