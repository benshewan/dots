{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.night-sky.programs.zen;

  # userChrome.js loader & scripts
  userchromejs-scripts = pkgs.fetchFromGitHub {
    owner = "aminomancer";
    repo = "uc.css.js";
    rev = "d79755e3e747bd8e2733c071fd9a783fa20f5584";
    sha256 = "sha256-baenZvd8fJDwdRXQIUmzx0El07DqCx3NjvxGzzQGipU=";
  };
  userchromejs-loader =
    lib.sources.sourceFilesBySuffices
    (pkgs.fetchFromGitHub {
      owner = "MrOtherGuy";
      repo = "fx-autoconfig";
      rev = "d597ff20583f6d948406a1ba1fbeb47bbe33a589";
      sha256 = "sha256-2rBvZauxGbo1//lbow7wntyLMZ9OJ17+YOssPgX8Q6s=";
    })
    [".js" ".mjs"];
in {
  options.night-sky.programs.zen = {
    enable = lib.mkEnableOption "zen";
  };

  config = lib.mkIf cfg.enable {
    home.file.".zen/profiles.ini".source = ./profiles.ini;
    home.file.".zen/default/user.js".source = ./user.js;

    # Custom userChrome.js scripts
    home.file.".zen/default/chrome" = {
      source = "${userchromejs-loader}/profile/chrome";
      recursive = true;
    };
    home.file.".zen/default/chrome/utils/chrome.manifest".text = let
      root = "${config.night-sky.user.home}/.zen/default/chrome";
    in ''
      content userchromejs ${root}/utils/
      content userscripts ${root}/JS/
      skin userstyles classic/1.0 ${root}/CSS/
      content userchrome ${root}/resources/
    '';

    # Private Tab
    home.file.".zen/default/chrome/JS/privateTabs.uc.js".source = ./privateTabs.uc.js;
    home.file.".zen/default/chrome/JS/privateWindowHomepage.uc.js".source = "${userchromejs-scripts}/JS/privateWindowHomepage.uc.js";

    home.packages = [
      (
        # pkgs.night-sky.zen-with-customjs
        pkgs.wrapFirefox pkgs.zen-browser-unwrapped {
          nativeMessagingHosts =
            [pkgs.goldwarden]
            ++ lib.optional config.services.kdeconnect.enable pkgs.kdePackages.plasma-browser-integration;

          extraPolicies = {
            CaptivePortal = false;
            DisableFirefoxStudies = true;
            DisablePocket = true;
            DisableTelemetry = true;
            DisableFirefoxAccounts = false;
            DisableSetDesktopBackground = true;
            DisableFeedbackCommands = true;
            DisableProfileImport = true;
            DontCheckDefaultBrowser = true;
            AutofillAddressEnabled = false;
            AutofillCreditCardEnabled = false;
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
              FeatureRecommendations = false;
              SkipOnboarding = true;
              MoreFromMozilla = false;
            };
            # Doesn't seem to work
            # SearchEngines.Default = "Google";
            # SearchEngines.Remove = ["eBay" "Wikipedia (en)"];
            # SearchEngines.Add = [
            #   {
            #     Description = "Google Search";
            #     IconURL = "https://www.google.com/favicon.ico";
            #     Method = "GET";
            #     Name = "Google (ca)";
            #     URLTemplate = "https://www.google.com/search?q={searchTerms}";
            #   }
            # ];
            Permissions.Notifications = {
              # Allow: ["https://example.org"],;
              # "Block": ["https://example.edu"],;
              BlockNewRequests = true;
              Locked = true;
            };

            # Firefox extensions
            ExtensionSettings = import ./extensions.nix;

            "3rdparty".Extensions = {
              "uBlock0@raymondhill.net" = {
                selectedFilterLists = [
                  "user-filters"
                  "ublock-filters"
                  "ublock-badware"
                  "ublock-privacy"
                  "ublock-quick-fixes"
                  "ublock-unbreak"
                  "easylist"
                  "easyprivacy"
                  "urlhaus-1"
                  "plowe-0"
                  "fanboy-cookiemonster"
                  "ublock-cookies-easylist"
                  "easylist-chat"
                  "easylist-newsletters"
                  "easylist-notifications"
                  "easylist-annoyances"
                ];
                userSettings = {
                  contextMenuEnabled = false;
                  importedLists = [];
                  popupPanelSections = 15;
                  showIconBadge = false;
                };
                userFilters = ''
                  ! Hello from NixOS!
                  ! Title: Hide YouTube Shorts
                  ! Description: Hide all traces of YouTube shorts videos on YouTube
                  ! Version: 1.10.0
                  ! Last modified: 2024-08-31 19:24
                  ! Expires: 2 weeks (update frequency)
                  ! Homepage: https://github.com/gijsdev/ublock-hide-yt-shorts
                  ! License: https://github.com/gijsdev/ublock-hide-yt-shorts/blob/master/LICENSE.md

                  ! Remove empty spaces in grid
                  www.youtube.com##ytd-rich-grid-row,#contents.ytd-rich-grid-row:style(display: contents !important)

                  ! Hide all videos containing the phrase "#shorts"
                  www.youtube.com##ytd-grid-video-renderer:has(#video-title:has-text(/(^| )#Shorts?( |$)/i))
                  www.youtube.com##ytd-rich-item-renderer:has(#video-title:has-text(/(^| )#Shorts?( |$)/i))

                  ! Hide all videos with the shorts indicator on the thumbnail
                  www.youtube.com##ytd-grid-video-renderer:has([overlay-style="SHORTS"])
                  www.youtube.com##ytd-rich-item-renderer:has([overlay-style="SHORTS"])
                  www.youtube.com##ytd-video-renderer:has([overlay-style="SHORTS"])
                  www.youtube.com##ytd-item-section-renderer.ytd-section-list-renderer[page-subtype="subscriptions"]:has(ytd-video-renderer:has([overlay-style="SHORTS"]))

                  ! Hide shorts button in sidebar
                  www.youtube.com##ytd-guide-entry-renderer:has(yt-formatted-string:has-text(/^Shorts$/i))
                  ! Tablet resolution
                  www.youtube.com##ytd-mini-guide-entry-renderer:has(.title:has-text(/^Shorts$/i))

                  ! Hide shorts sections except on history page
                  www.youtube.com##:matches-path(/^(?!\/feed\/history).*$/)ytd-rich-section-renderer:has(#title:has-text(/(^| )Shorts( |$)/i))
                  www.youtube.com##:matches-path(/^(?!\/feed\/history).*$/)ytd-reel-shelf-renderer:has(.ytd-reel-shelf-renderer:has-text(/(^| )Shorts( |$)/i))

                  ! Hide shorts tab on channel pages`
                  ! Old style
                  www.youtube.com##tp-yt-paper-tab:has(.tp-yt-paper-tab:has-text(Shorts))
                  ! New style (2023-10)
                  www.youtube.com##yt-tab-shape:has-text(/^Shorts$/)

                  ! Hide short remixes in video descriptions and in suggestions beside the comments
                  www.youtube.com##ytd-reel-shelf-renderer:has(#title:has-text(/(^| )Shorts.?Remix.*$/i))

                  ! Hide shorts category on homepage and search pages
                  www.youtube.com##yt-chip-cloud-chip-renderer:has(yt-formatted-string:has-text(/^Shorts$/i))

                  !!! MOBILE !!!

                  ! Hide all videos in home feed containing the phrase "#shorts"
                  www.youtube.com##ytm-rich-item-renderer:has(#video-title:has-text(/(^| )#Shorts?( |$)/i))

                  ! Hide all videos in subscription feed containing the phrase "#shorts"
                  m.youtube.com##ytm-item-section-renderer:has(#video-title:has-text(/(^| )#Shorts?( |$)/i))

                  ! Hide shorts button in the bottom navigation bar
                  m.youtube.com##ytm-pivot-bar-item-renderer:has(.pivot-shorts)

                  ! Hide all videos with the shorts indicator on the thumbnail
                  m.youtube.com##ytm-video-with-context-renderer:has([data-style="SHORTS"])

                  ! Hide shorts sections except on history page
                  m.youtube.com##:matches-path(/^(?!\/feed\/history).*$/)ytm-rich-section-renderer:has(.reel-shelf-title-wrapper .yt-core-attributed-string:has-text(/(^| )Shorts( |$)/i))
                  m.youtube.com##:matches-path(/^(?!\/feed\/history).*$/)ytm-reel-shelf-renderer.item:has(.reel-shelf-title-wrapper .yt-core-attributed-string:has-text(/(^| )Shorts( |$)/i))

                  ! Hide shorts tab on channel pages
                  ! Old style
                  m.youtube.com##.single-column-browse-results-tabs>a:has-text(Shorts)
                  ! New style (2023-10)
                  m.youtube.com##yt-tab-shape:has-text(/^Shorts$/)

                  ! Hide short remixes in video descriptions and in suggestions below the player
                  m.youtube.com##ytm-reel-shelf-renderer:has(.reel-shelf-title-wrapper .yt-core-attributed-string:has-text(/(^| )Shorts.?Remix.*$/i))

                  ! Hide shorts category on homepage
                  m.youtube.com##ytm-chip-cloud-chip-renderer:has(.yt-core-attributed-string:has-text(/^Shorts$/i))
                '';
              };
            };
          };
        }
      )
    ];
  };
}
