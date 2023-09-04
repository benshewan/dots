{ pkgs, config, lib, inputs, username, ... }:
let
  firefox-userchromejs = pkgs.fetchgit {
    url = "https://github.com/alice0775/userChrome.js.git";
    rev = "f11141337a931bb75e3b269f68562626b1d83f54";
    sha256 = "0sbq2z9xwxxw06c10i17amjq4lzmj2dvbpsyf47daszlf59qshnw";
  };
  firefox-cascade-theme = pkgs.fetchFromGitHub {
    owner = "andreasgrafen";
    repo = "cascade";
    rev = "2f70e8619ce5c721fe9c0736b25c5a79938f1215";
    sha256 = "sha256-HOOBQ1cNjsDTFSymB3KjiZ1jw3GL16LF/RQxdn0sxr0=";
  };
  firefoxPackage = pkgs.firefox-devedition-unwrapped.overrideAttrs (old: {
    postInstall = ''
      mkdir -p $out/lib/firefox/browser/defaults/preferences
      ln -s ${firefox-userchromejs}/117/install_folder/config.js $out/lib/firefox/config.js
      ln -s ${firefox-userchromejs}/117/install_folder/defaults/pref/config-prefs.js $out/lib/firefox/browser/defaults/preferences/config-prefs.js
    '';
  });
in
{
  # Custom userChrome.js files
  home.file.".mozilla/firefox/dev-edition-default/chrome/MouseGestures2_e10s.uc.js".source = "${firefox-userchromejs}/117/MouseGestures2_e10s.uc.js";

  # Custom theme
  home.file.".mozilla/firefox/dev-edition-default/chrome/includes" = {
    recursive = true;
    source = "${firefox-cascade-theme}/chrome/includes";
  };
  home.file.".mozilla/firefox/dev-edition-default/chrome/integrations/cascade-tcr.css".source = "${firefox-cascade-theme}/integrations/tabcenter-reborn/cascade-tcr.css";
  home.file.".mozilla/firefox/dev-edition-default/chrome/userChrome.css".text = builtins.readFile "${firefox-cascade-theme}/chrome/userChrome.css" + ''
    @import 'integrations/cascade-tcr.css';
    /* Sidebery */
    #sidebar-box[sidebarcommand="_3c078156-979c-498b-8990-85f7987dd929_-sidebar-action"] #sidebar-header {
      visibility: collapse;
    }

    /* Source file https://github.com/MrOtherGuy/firefox-csshacks/tree/master/chrome/autohide_sidebar.css made available under Mozilla Public License v. 2.0
    See the above repository for updates as well as full license text. */

    /* Show sidebar only when the cursor is over it  */
    /* The border controlling sidebar width will be removed so you'll need to modify these values to change width */

    #sidebar-box[sidebarcommand="_3c078156-979c-498b-8990-85f7987dd929_-sidebar-action"] {
      --uc-sidebar-width: 48px !important;
      --uc-sidebar-hover-width: 250px;
      --uc-autohide-sidebar-delay: 300ms; /* Wait 0.3s before hiding sidebar */
      position: relative;
      min-width: var(--uc-sidebar-width) !important;
      width: var(--uc-sidebar-width) !important;
      max-width: var(--uc-sidebar-width) !important;
      z-index:1;
    }

    #sidebar-box[sidebarcommand="_3c078156-979c-498b-8990-85f7987dd929_-sidebar-action"] > #sidebar-splitter {
      display: none
    }

    #sidebar-box[sidebarcommand="_3c078156-979c-498b-8990-85f7987dd929_-sidebar-action"] > #sidebar {
      transition: min-width 115ms linear var(--uc-autohide-sidebar-delay) !important;
      min-width: var(--uc-sidebar-width) !important;
      will-change: min-width;
    }

    #sidebar-box[sidebarcommand="_3c078156-979c-498b-8990-85f7987dd929_-sidebar-action"]:hover > #sidebar{
      min-width: var(--uc-sidebar-hover-width) !important;
      transition-delay: 0ms !important
    }

    /* Add sidebar divider and give it background */

    #sidebar-box[sidebarcommand="_3c078156-979c-498b-8990-85f7987dd929_-sidebar-action"] > #sidebar,
    #sidebar-box[sidebarcommand="_3c078156-979c-498b-8990-85f7987dd929_-sidebar-action"] > #sidebar-header {
      background-color: var(--toolbar-bgcolor) !important;
    /*  border-inline: 1px solid var(--sidebar-border-color) !important;*/
      border-inline: 1px solid var(--chrome-content-separator-color) !important;
      border-inline-width: 0px 1px;
    }
    #sidebar-box[positionend]{
      direction: rtl
    }
    #sidebar-box[positionend] > *{
      direction: ltr
    }

    #sidebar-box[positionend]:-moz-locale-dir(rtl){
      direction: ltr
    }
    #sidebar-box[positionend]:-moz-locale-dir(rtl) > *{
      direction: rtl
    }
  '';


  programs.firefox = {
    enable = true;
    package = pkgs.firefox-devedition.override {

      cfg.enablePlasmaBrowserIntegration = true;
      # cfg.enableGnomeExtensions = lib.optional (config.services.xserver.desktopManager.gnome.enable or false) true;
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

        Preferences = {
          "browser.startup.page" = 3;
          toolkit.legacyUserProfileCustomizations.stylesheets = true;
        };

        # Firefox extensions
        ExtensionSettings = {
          "*" = {
            blocked_install_message = "All extensions must be declared in you home-manager config";
            install_sources = [ "https://github.com/benshewan/dots/*" ];
            installation_mode = "blocked";
            allowed_types = [ "extension" ];
          };
          # Helps add extensions to firefox policy
          "queryamoid@kaply.com" = {
            installation_mode = "force_installed";
            install_url = "https://github.com/mkaply/queryamoid/releases/download/v0.1/query_amo_addon_id-0.1-fx.xpi";
          };
          # Mouse Gestures - TODO: replace with userchromejs script to enable wider use
          "{e839c3f9-298e-4cd0-99e0-464431cb7c34}" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/foxy-gestures/latest.xpi";
          };
          # Password Manager
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
            installation_mode = "force_installed";
            default_area = "navbar";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          };
          # AD Blocker
          "uBlock0@raymondhill.net" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          };
          # View the web in dark mode
          "addon@darkreader.org" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
          };
          # Youtube customization
          "{3c6bf0cc-3ae2-42fb-9993-0d33104fdcaf}" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/youtube-addon/latest.xpi";
          };
          # Blocks Sponsor segments on Youtube videos
          "sponsorBlocker@ajay.app" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
          };
          # Integration with KDE
          "plasma-browser-integration@kde.org" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/plasma-integration/latest.xpi";
          };
          # "gsconnect@andyholmes.github.io" = lib.mkIf (lib.elem pkgs.gnomeExtensions.gsconnect config.home.packages) {
          #   installation_mode = "force_installed";
          #   install_url = "https://addons.mozilla.org/firefox/downloads/latest/gsconnect/latest.xpi";
          # };
          # Bypass Website Paywalls
          "magnolia@12.34" = {
            installation_mode = "force_installed";
            install_url = "https://gitlab.com/magnolia1234/bpc-uploads/-/raw/master/bypass_paywalls_clean-latest.xpi";
          };
          # Sidebery Tabs
          "{3c078156-979c-498b-8990-85f7987dd929}" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/sidebery/latest.xpi";
          };
          # Torrent Control
          "{e6e36c9a-8323-446c-b720-a176017e38ff}" = {
            installation_mode = "force_installed";
            default_area = "menupanel";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/torrent-control/latest.xpi";
          };
          # NZB Downloader
          "{96586e48-b9a2-45dd-b1a1-54fa85a97c91}" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/nzb-unity/latest.xpi";
          };
          # Google Translate - TODO: Firefox is slowly replacing this with its own builtin translator, but doesn't yet support languages like russian or japanese
          "{036a55b4-5e72-4d05-a06c-cba2dfcc134a}" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/traduzir-paginas-web/latest.xpi";
          };
        };
      };
    };
    profiles = {
      dev-edition-default = {
        id = 0;
        isDefault = true;
        extraConfig = builtins.fetchurl {
          url = "https://raw.githubusercontent.com/yokoffing/Betterfox/4e44dc28202cda4b0b92401157839bf511dfceb3/user.js";
          sha256 = "1islaj99psf20n8f072g84rni32l5lxh53dwg3mlc05h3k5n7i6j";
        };
      };
    };
  };
}
