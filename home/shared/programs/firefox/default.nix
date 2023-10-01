{
  pkgs,
  lib,
  config,
  ...
}: let
  # userChrome.js loader
  firefox-userchromejs = pkgs.fetchFromGitHub {
    owner = "xiaoxiaoflood";
    repo = "firefox-scripts";
    rev = "b013243f1916576166a02d816651c2cc6416f63e";
    sha256 = "sha256-Zp1pRMqgAM3Xh3JCkAC0hWp2Gl2phkyAwJ8KB2tA9jE=";
  };
  # Patched userChrome.js loader files for firefox 117+
  userchromejs-utils = pkgs.fetchzip {
    url = "https://github.com/xiaoxiaoflood/firefox-scripts/files/12099137/utils.zip";
    sha256 = "sha256-MBdyxByEA85JhLCa9mXLHuB9RI4F9qCZvG3446eO7lQ=";
  };

  # Custom CSS styles
  firefox-gnome-dark = (import ./gnome-theme.nix {inherit pkgs config;}).dark;
  firefox-gnome-theme =
    builtins.filterSource (path: type: type == "directory" || baseNameOf path != "dark.css")
    (pkgs.fetchFromGitHub {
      owner = "rafaelmardojai";
      repo = "firefox-gnome-theme";
      rev = "67cc89691b17bc09f110efa7fd6011c19d763597";
      sha256 = "sha256-SnSXskFvJP1OMFuDdhuxxbFpQKzSz3YLJyoxWscmDSA=";
    });

  # Add userChrome.js loader to firefox developer edition (Warning: Will force firefox to recompile!)
  firefoxPackage = pkgs.firefox-devedition-unwrapped.overrideAttrs (old: {
    postInstall = ''
      mkdir -p $out/lib/firefox/browser/defaults/preferences
      cp ${firefox-userchromejs}/installation-folder/config.js $out/lib/firefox/config.js
      cp ${firefox-userchromejs}/installation-folder/config-prefs.js $out/lib/firefox/browser/defaults/preferences/config-prefs.js
    '';
  });
in {
  # Custom userChrome.js scripts
  home.file.".mozilla/firefox/dev-edition-default/chrome/utils" = {
    source = userchromejs-utils;
    recursive = true;
  };
  # userChrome.js manager
  home.file.".mozilla/firefox/dev-edition-default/chrome/rebuild_userChrome.uc.js".source = "${firefox-userchromejs}/chrome/rebuild_userChrome.uc.js";
  # Private Tab
  home.file.".mozilla/firefox/dev-edition-default/chrome/privateTab.uc.js".source = "${firefox-userchromejs}/chrome/privateTab.uc.js";
  # Mouse gestures
  home.file.".mozilla/firefox/dev-edition-default/chrome/mouseGestures" = {
    source = "${firefox-userchromejs}/chrome/mouseGestures";
    recursive = true;
  };
  home.file.".mozilla/firefox/dev-edition-default/chrome/mouseGestures.uc.js".source = ./mouseGestures.uc.js;

  # Custom theme
  home.file.".mozilla/firefox/dev-edition-default/chrome/userChrome.css".source = "${firefox-gnome-theme}/userChrome.css";
  home.file.".mozilla/firefox/dev-edition-default/chrome/userContent.css".source = "${firefox-gnome-theme}/userContent.css";
  home.file.".mozilla/firefox/dev-edition-default/chrome/theme" = {
    recursive = true;
    source = "${firefox-gnome-theme}/theme";
  };
  home.file.".mozilla/firefox/dev-edition-default/chrome/theme/colors".enable = false;
  home.file.".mozilla/firefox/dev-edition-default/chrome/customChrome.css".source = ./customChrome.css;
  home.file.".mozilla/firefox/dev-edition-default/chrome/theme/colors/dark.css".source = firefox-gnome-dark;

  programs.firefox = {
    enable = true;
    package = pkgs.wrapFirefox firefoxPackage {
      # Enable Native Messaging Hosts
      cfg.enablePlasmaBrowserIntegration = true;
      # cfg.enableGnomeExtensions = if (lib.elem pkgs.gnomeExtensions.gsconnect config.home.packages) then true else false;
      # extraNativeMessagingHosts = [ ]
      #   ++ lib.optional (lib.elem pkgs.gnomeExtensions.gsconnect config.home.packages) pkgs.gnomeExtensions.gsconnect;

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
        EncryptedMediaExtensions.Enabled = true;
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

        # Firefox extensions
        ExtensionSettings = import ./extensions.nix {inherit pkgs;};
      };
    };
    profiles = {
      dev-edition-default = {
        id = 0;
        isDefault = true;
        extraConfig =
          builtins.readFile
          (builtins.fetchurl
            {
              url = "https://raw.githubusercontent.com/yokoffing/Betterfox/4e44dc28202cda4b0b92401157839bf511dfceb3/user.js";
              sha256 = "1islaj99psf20n8f072g84rni32l5lxh53dwg3mlc05h3k5n7i6j";
            })
          + ''
            user_pref("browser.startup.page", 3); // browser should restore previous session
            user_pref("widget.gtk.ignore-bogus-leave-notify", 1); //fix for hover on drag (fixes sideberry tab drag)

            // Firefox Gnome Theme Tweaks
            user_pref("gnomeTheme.extensions.tabCenterReborn", true);
            user_pref("svg.context-properties.content.enabled", true);
            user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
          '';
      };
    };
  };
}
