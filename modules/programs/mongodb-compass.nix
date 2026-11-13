{config, ...}: let
  username = config.flake.meta.user.username;
in {
  flake.modules.homeManager."programs/mongodb-compass" = {pkgs, ...}: {
    home.packages = with pkgs; [
      mongodb-compass
      mongodb-tools
    ];

    # xdg-mime writes ~/.config/mimeapps.list via sed -i (atomic rename), so
    # this scheme registration cannot be preserved with a file bind mount —
    # declare it instead.
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/mongodb" = "mongodb-compass.desktop";
        "x-scheme-handler/mongodb+srv" = "mongodb-compass.desktop";
      };
      associations.added = {
        "x-scheme-handler/mongodb" = "mongodb-compass.desktop";
        "x-scheme-handler/mongodb+srv" = "mongodb-compass.desktop";
      };
    };

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

  # Preservation companion for "programs/mongodb-compass" (auto-resolved by
  # the prefix).
  # - ".mongodb/compass" is rotated gzipped logs only — left volatile.
  flake.modules.nixos."preservation/programs/mongodb-compass" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username} = {
      directories = [
        # Electron profile: connections, cookies, preferences, workspace
        # state (same whole-dir rationale as .config/Code).
        ".config/MongoDB Compass"

        # NSS client-certificate store Compass initializes on first run
        # (used for client-side TLS certs).
        ".local/share/pki"
      ];
    };
  };
}
