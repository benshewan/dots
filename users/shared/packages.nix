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

  programs.plasma = {
    enable = true;

    # Some high-level settings:
    workspace.clickItemTo = "select";

    # hotkeys.commands."Launch Konsole" = {
    #   key = "Meta+Alt+K";
    #   command = "konsole";
    # };

    # Some mid-level settings:
    # shortcuts = {
    #   ksmserver = {
    #     "Lock Session" = [ "Screensaver" "Meta+Ctrl+Alt+L" ];
    #   };

    #   kwin = {
    #     "Expose" = "Meta+,";
    #     "Switch Window Down" = "Meta+J";
    #     "Switch Window Left" = "Meta+H";
    #     "Switch Window Right" = "Meta+L";
    #     "Switch Window Up" = "Meta+K";
    #   };
    # };

    # A low-level setting:
    configFile."kdeglobals"."KDE"."widgetStyle" = "Lightly";
    configFile."kdeglobals"."General"."BrowserApplication" = "firefox.desktop";
  };
}
