{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.night-sky.programs.firefox;

  # Name of firefox profile (P.S. should be "default" in regular firefox and "dev-edition-default" for firefox dev edition)
  profile = "default";
in {
  options.night-sky.programs.firefox = {
    enable = lib.mkEnableOption "firefox";
  };

  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      package = pkgs.firefox;
      nativeMessagingHosts =
        [pkgs.goldwarden]
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
        OfferToSaveLoginsDefault = false;
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
        "3rdparty".Extensions."uBlock0@raymondhill.net" = {
          adminSettings = {
            userSettings = {
              contextMenuEnabled = false;
              showIconBadge = false;
              externalLists = "https://raw.githubusercontent.com/mchangrh/yt-neuter/main/filters/noshorts.txt\nhttps://raw.githubusercontent.com/mchangrh/yt-neuter/main/filters/premium.txt\nhttps://raw.githubusercontent.com/mchangrh/yt-neuter/main/filters/sponsorblock.txt";
              importedLists = [
                "https://raw.githubusercontent.com/mchangrh/yt-neuter/main/filters/noshorts.txt"
                "https://raw.githubusercontent.com/mchangrh/yt-neuter/main/filters/premium.txt"
                "https://raw.githubusercontent.com/mchangrh/yt-neuter/main/filters/sponsorblock.txt"
              ];
            };
            selectedFilterLists = [
              "user-filters"
              "assets.json"
              "public_suffix_list.dat"
              "ublock-badlists"
              "ublock-filters"
              "ublock-badware"
              "ublock-privacy"
              "ublock-unbreak"
              "ublock-quick-fixes"
              "easylist"
              "easyprivacy"
              "urlhaus-1"
              "plowe-0"
              "https://raw.githubusercontent.com/mchangrh/yt-neuter/main/filters/noshorts.txt"
              "https://raw.githubusercontent.com/mchangrh/yt-neuter/main/filters/premium.txt"
              "https://raw.githubusercontent.com/mchangrh/yt-neuter/main/filters/sponsorblock.txt"
            ];
            userFilters = "||smartlock.google.com";
          };
        };

        # Firefox extensions
        ExtensionSettings = import ./extensions.nix;
      };
      profiles = {
        "${profile}" = {
          id = 0;
          isDefault = true;
          extraConfig =
            builtins.readFile
            (builtins.fetchurl
              {
                url = "https://raw.githubusercontent.com/yokoffing/Betterfox/4b75f957f9c40a564c270614add472db3d3df9fa/user.js";
                sha256 = "1aix07xv1bzrz2lflr0x56x172l9wphcm32qhmxrm5rwlm3mjzrw";
              })
            # Overrides
            + builtins.readFile ./user.js;
        };
      };
    };
  };
}
