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
      nativeMessagingHosts = [pkgs.tridactyl-native];

      # Enterprise Polices ---------------------------------------------
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

        AutofillAddressEnabled = false;
        AutofillCreditCardEnabled = false;

        DisableFormHistory = true;

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

        # Searching ---------------------------------------------
        SearchSuggestEnabled = false;
        SearchEngines = {
          PreventInstalls = true;
          Remove = [
            "eBay"
            # "Google"
            "Bing"
            "Ecosia"
            "Wikipedia"
            "Perplexity"
          ];
          Add = [
            {
              "Name" = "Brave Search";
              "URLTemplate" = "https://search.brave.com/search?q={searchTerms}&summary=0";
              "IconURL" = "https://cdn.search.brave.com/serp/v1/static/brand/eebf5f2ce06b0b0ee6bbd72d7e18621d4618b9663471d42463c692d019068072-brave-lion-favicon.png";
              "Alias" = "brave";
            }
            {
              "Name" = "DuckDuckGo";
              "URLTemplate" = "https://duckduckgo.com/?q={searchTerms}&ia=web&assist=false";
              "IconURL" = "https://duckduckgo.com/favicon.ico";
              "Alias" = "ddg";
              "Description" = "Duckduckgo without AI integrations";
            }
            {
              "Name" = "Wikipedia";
              "URLTemplate" = "https://en.wikipedia.org/wiki/Special:Search?go=Go&search={searchTerms}";
              "IconURL" = "https://en.wikipedia.org/favicon.ico";
              "Alias" = "wiki";
            }
          ];
          Default = "Google";
        };

        # Disable browser Notification ---------------------------------------------
        Permissions.Notifications = {
          # Allow: ["https://example.org"],;
          # "Block": ["https://example.edu"],;
          BlockNewRequests = true;
          Locked = true;
        };
      };

      # Betterfox + Custom Settings ---------------------------------------------
      profiles = {
        "${profile}" = {
          id = 0;
          path = profile;
          isDefault = true;
          extraConfig =
            builtins.readFile
            (builtins.fetchurl
              {
                url = "https://raw.githubusercontent.com/yokoffing/Betterfox/067172a4b0dc90e78e5b8b94d9abfe6430c6a7be/user.js";
                sha256 = "sha256:0h2j5lsv07r81qp8ysjg3d9i9cdzhjw9ip96mxxrh9ajn73p3a9q";
              })
            # Overrides
            + builtins.readFile ./user.js;
        };
      };
    };
  };
}
