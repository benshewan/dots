{...}: {
  flake.modules.homeManager."programs/firefox" = {
    pkgs,
    config,
    lib,
    ...
  }: let
    # Name of firefox profile (P.S. should be "default" in regular firefox and "dev-edition-default" for firefox dev edition)
    profile = "dev-edition-default";
  in {
    # Move browser profile into ram disk
    # services.psd.enable = true;
    # services.psd.browsers = ["firefox"];

    # only works for firefox color addon or firefox gnome theme
    stylix.targets.firefox.enable = false;

    programs.firefox.configPath = "${config.xdg.configHome}/mozilla/firefox";
    home.file.".mozilla/native-messaging-hosts".enable = false;

    programs.firefox = {
      enable = true;
      nativeMessagingHosts =
        [pkgs.tridactyl-native]
        ++ lib.optional config.services.kdeconnect.enable pkgs.kdePackages.plasma-browser-integration;
      policies = {
        CaptivePortal = false;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DisableFirefoxAccounts = false;
        DisableSetDesktopBackground = true;
        DisableFeedbackCommands = true;
        DisableProfileImport = true;
        DontCheckDefaultBrowser = true;
        EncryptedMediaExtensions = {
          Enabled = true;
          Locked = true;
        };
        NoDefaultBookmarks = true;
        OfferToSaveLogins = false;
        PasswordManagerEnabled = false;
        FirefoxHome = {
          Search = true;
          Pocket = false;
          Snippets = false;
          TopSites = false;
          Highlights = false;
        };
        UserMessaging = {
          ExtensionRecommendations = false;
          SkipOnboarding = true;
        };
        SearchEngines.Default = "Google";
        Permissions.Notifications = {
          # Allow: ["https://example.org"],;
          # "Block": ["https://example.edu"],;
          BlockNewRequests = true;
          Locked = true;
        };
      };
      profiles = {
        "${profile}" = {
          id = 0;
          isDefault = true;
          extraConfig =
            builtins.readFile
            (builtins.fetchurl
              {
                url = "https://raw.githubusercontent.com/yokoffing/Betterfox/f1c8e3809dbd23f4f9aa1e5e70805c61734b1f14/user.js";
                sha256 = "sha256:1cz6fbbhg30ci795inmb8l1l95qln565lasv1142cdh5syn6jr6s";
              })
            # Overrides
            + builtins.readFile ./user.js;
        };
      };
    };
  };
}
