{
  pkgs,
  lib,
  config,
  ...
}: let
  # userChrome.js loader
  userchromejs-scripts = pkgs.fetchFromGitHub {
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
      rev = "cd408d8e4de8bd514387366dda4fe0def6e43c16";
      hash = "sha256-1NjteDq4fhEWFtlKd3DPYWHdU53qEQEqZB2DCxKpayE=";
    });
in {
  # Custom userChrome.js scripts
  home.file.".mozilla/firefox/dev-edition-default/chrome/utils" = {
    source = userchromejs-utils;
    recursive = true;
  };
  # userChrome.js manager
  home.file.".mozilla/firefox/dev-edition-default/chrome/rebuild_userChrome.uc.js".source = "${userchromejs-scripts}/chrome/rebuild_userChrome.uc.js";
  # Private Tab
  home.file.".mozilla/firefox/dev-edition-default/chrome/privateTab.uc.js".source = "${userchromejs-scripts}/chrome/privateTab.uc.js";
  # Mouse gestures
  home.file.".mozilla/firefox/dev-edition-default/chrome/mouseGestures" = {
    source = "${userchromejs-scripts}/chrome/mouseGestures";
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
    package = pkgs.wrapFirefox pkgs.firefox-devedition-unwrapped {
      # Enable Native Messaging Hosts
      # nativeMessagingHosts = [
      # pkgs.plasma-browser-integration
      # pkgs.gnomeExtensions.gsconnect
      # ];
      # cfg.enableGnomeExtensions = if (lib.elem pkgs.gnomeExtensions.gsconnect config.home.packages) then true else false;
      # extraNativeMessagingHosts = [ ]
      #   ++ lib.optional (lib.elem pkgs.gnomeExtensions.gsconnect config.home.packages) pkgs.gnomeExtensions.gsconnect;
    };
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

      # Firefox extensions
      ExtensionSettings = import ./extensions.nix {inherit pkgs;};
    };
    profiles = {
      dev-edition-default = {
        id = 0;
        isDefault = true;
        extraConfig =
          builtins.readFile
          (builtins.fetchurl
            {
              url = "https://raw.githubusercontent.com/yokoffing/Betterfox/4b75f957f9c40a564c270614add472db3d3df9fa/user.js";
              sha256 = "1aix07xv1bzrz2lflr0x56x172l9wphcm32qhmxrm5rwlm3mjzrw";
            })
          + ''
            //SmoothFox
            user_pref("apz.overscroll.enabled", true); // DEFAULT NON-LINUX
            user_pref("general.smoothScroll", true); // DEFAULT
            user_pref("general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS", 12);
            user_pref("general.smoothScroll.msdPhysics.enabled", true);

            // Overrides
            user_pref("browser.startup.page", 3); // browser should restore previous session
            //fix for hover on drag (fixes sideberry tab drag, does not work on hyprland) https://bugzilla.mozilla.org/show_bug.cgi?id=1818517
            user_pref("widget.gtk.ignore-bogus-leave-notify", 1);
            user_pref("widget.use-xdg-desktop-portal", true); // tell firefox to use my XDG Portal
            user_pref("browser.tabs.firefox-view-next", false); // disable firefox view
            user_pref("browser.download.useDownloadDir", true); // one-click downloads
            user_pref("accessibility.force_disabled", 1); // disable Accessibility features
            user_pref("browser.toolbars.bookmarks.visibility", "never"); // always hide bookmark bar
            user_pref("browser.urlbar.trimHttps", true); // hide https in URL bar [FF119]
            user_pref("media.videocontrols.picture-in-picture.display-text-tracks.size", "small"); // PiP
            user_pref("media.videocontrols.picture-in-picture.urlbar-button.enabled", false); // PiP in address bar
            user_pref("network.trr.confirmationNS", "skip"); // skip TRR confirmation request
            user_pref("extensions.webextensions.restrictedDomains", ""); // remove Mozilla domains so adblocker works on pages
            user_pref("browser.sessionstore.restore_pinned_tabs_on_demand", true);
            user_pref("browser.sessionhistory.max_total_viewers", 4); // only remember # of pages in Back-Forward cache
            user_pref("media.eme.enabled", true); // enable DRM protected content
            user_pref("browser.eme.ui.enabled", false); // hide DRM ui
            user_pref("identity.fxaccounts.enabled", true); // enable firefox sync
            user_pref("browser.tabs.firefox-view", false); // disable firefox view

            /** for 12 GB+ RAM ***/
            user_pref("browser.cache.disk.enable", false);
            user_pref("browser.cache.memory.capacity", 256000); // default= -1 (32768)
            user_pref("browser.cache.memory.max_entry_size", 10240); // default=5120 (5 MB)
            user_pref("media.memory_cache_max_size", 131072); // default=8192; AF=65536
            user_pref("media.memory_caches_combined_limit_kb", 1048576); // default=524288
            user_pref("media.memory_caches_combined_limit_pc_sysmem", 10); // default=5

            /** speculative load test ***/
            user_pref("network.dns.disablePrefetchFromHTTPS", false);
            //user_pref("network.prefetch-next", true);
            user_pref("network.predictor.enabled", true);
            user_pref("network.predictor.enable-prefetch", true);
            user_pref("network.predictor.enable-hover-on-ssl", true);

            // Firefox Gnome Theme Tweaks
            user_pref("gnomeTheme.extensions.tabCenterReborn", true);
            user_pref("svg.context-properties.content.enabled", true);
            user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
          '';
      };
    };
  };
}
