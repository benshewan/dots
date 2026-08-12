_: {
  flake.modules.homeManager."programs/mongodb-compass" = {pkgs, ...}: {
    home.packages = with pkgs; [
      mongodb-compass
      mongodb-tools
    ];

    xdg.desktopEntries = {
      "mongodb-compass" = {
        exec = ''env MONGODB_COMPASS_TEST_LOG_DIR=/dev/null ELECTRON_OZONE_PLATFORM_HINT=auto mongodb-compass --ignore-additional-command-line-flags --password-store="gnome-libsecret" %U'';
        name = "MongoDB Compass";
        genericName = "MongoDB Compass";
        comment = "The MongoDB GUI";
        mimeType = ["x-scheme-handler/mongodb" "x-scheme-handler/mongodb+srv"];
        icon = "mongodb-compass";
        categories = ["GNOME" "GTK" "Utility"];
        type = "Application";
      };
    };
  };
}
