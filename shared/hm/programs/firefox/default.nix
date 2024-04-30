{
  pkgs,
  config,
  outputs,
  lib,
  ...
}: let
  # Name of firefox profile (P.S. should be "default" in regular firefox and "dev-edition-default" for firefox dev edition)
  profile = "dev-edition-default";
  # userChrome.js loader & scripts
  userchromejs-scripts = pkgs.fetchFromGitHub {
    owner = "aminomancer";
    repo = "uc.css.js";
    rev = "2b39f40d2f1489fa26f1da0ca6e4887f8987d9f8";
    sha256 = "sha256-7JyjsD73DFSO9CGAZeRt9938WYCVjqB5BVq93VDu8MU=";
  };
  userchromejs-loader =
    lib.sources.sourceFilesBySuffices
    (pkgs.fetchFromGitHub {
      owner = "MrOtherGuy";
      repo = "fx-autoconfig";
      rev = "d9133f188d4a037d9bf71aa208d1452d78adb25c";
      sha256 = "sha256-wJHcthpwoBi+T6NXkxwG+ePTHnIvut7Tr0UJDEOGL2U=";
      sparseCheckout = [
        "profile/chome/utils"
        "profile/chrome/JS"
      ];
    })
    [".js" ".mjs"];

  # Custom CSS styles
  firefox-gnome-dark = (import ./gnome-theme.nix {inherit pkgs config;}).dark;
  firefox-gnome-theme =
    builtins.filterSource (path: type: type == "directory" || baseNameOf path != "dark.css")
    (pkgs.fetchFromGitHub {
      owner = "rafaelmardojai";
      repo = "firefox-gnome-theme";
      rev = "5501717d3e98fcc418a2ca40de1c5ad1b66939bb";
      hash = "sha256-6K95wxghPBS1sJMnuKJ4JD3jLd/5bAEmx7rnffqf29I=";
    });
in {
  # Custom userChrome.js scripts
  home.file.".mozilla/firefox/${profile}/chrome" = {
    source = "${userchromejs-loader}/profile/chrome";
    recursive = true;
  };

  home.file.".mozilla/firefox/${profile}/chrome/utils/chrome.manifest".text = let
    root = "/home/${outputs.username}/.mozilla/firefox/${profile}/chrome";
  in ''
    content userchromejs ${root}/utils/
    content userscripts ${root}/JS/
    skin userstyles classic/1.0 ${root}/CSS/
    content userchrome ${root}/resources/
  '';

  # Private Tab
  home.file.".mozilla/firefox/${profile}/chrome/JS/privateTabs.uc.js".source = "${userchromejs-scripts}/JS/privateTabs.uc.js";
  home.file.".mozilla/firefox/${profile}/chrome/JS/privateWindowHomepage.uc.js".source = "${userchromejs-scripts}/JS/privateWindowHomepage.uc.js";

  home.file.".mozilla/firefox/${profile}/chrome/JS/findbarMods.uc.js".source = "${userchromejs-scripts}/JS/findbarMods.uc.js";
  home.file.".mozilla/firefox/${profile}/chrome/JS/hideTrackingProtectionIconOnCustomNewTabPage.uc.js".source = "${userchromejs-scripts}/JS/hideTrackingProtectionIconOnCustomNewTabPage.uc.js";

  # Custom theme
  home.file.".mozilla/firefox/${profile}/chrome/userChrome.css".text =
    (builtins.readFile "${firefox-gnome-theme}/userChrome.css")
    + ''
      @import "${./multi_column_addons.css}";
    '';
  home.file.".mozilla/firefox/${profile}/chrome/userContent.css".source = "${firefox-gnome-theme}/userContent.css";
  home.file.".mozilla/firefox/${profile}/chrome/theme" = {
    recursive = true;
    source = "${firefox-gnome-theme}/theme";
  };
  home.file.".mozilla/firefox/${profile}/chrome/theme/colors".enable = false;
  home.file.".mozilla/firefox/${profile}/chrome/theme/colors/dark.css".source = firefox-gnome-dark;

  # Add aditional css changes
  home.file.".mozilla/firefox/${profile}/chrome/customChrome.css".source = ./customChrome.css;

  # Stylix support
  stylix.targets.firefox.profileNames = [profile];

  programs.firefox = {
    enable = true;
    package = pkgs.wrapFirefox pkgs.firefox-devedition-unwrapped {};
    nativeMessagingHosts =
      [pkgs.goldwarden]
      ++ lib.optional config.services.kdeconnect.enable pkgs.plasma-browser-integration;
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
      ExtensionSettings = import ./extensions.nix {inherit pkgs;};
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
}
