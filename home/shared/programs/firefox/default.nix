{ pkgs, lib, config, ... }:
let
  # userChrome.js loader
  firefox-userchromejs = pkgs.fetchFromGitHub {
    owner = "xiaoxiaoflood";
    repo = "firefox-scripts";
    rev = "b013243f1916576166a02d816651c2cc6416f63e";
    sha256 = "sha256-Zp1pRMqgAM3Xh3JCkAC0hWp2Gl2phkyAwJ8KB2tA9jE=";
  };
  # Custom CSS styles
  # firefox-gnome-dark = (import ./firefox-gnome-theme.nix).gnome-theme; # ????
  firefox-gnome-theme = pkgs.fetchFromGitHub {
    owner = "rafaelmardojai";
    repo = "firefox-gnome-theme";
    rev = "67cc89691b17bc09f110efa7fd6011c19d763597";
    sha256 = "sha256-SnSXskFvJP1OMFuDdhuxxbFpQKzSz3YLJyoxWscmDSA=";
  };

  # Add userChrome.js loader to firefox developer edition (Warning: Will force firefox to recompile!)
  firefoxPackage = pkgs.firefox-devedition-unwrapped.overrideAttrs (old: {
    postInstall = ''
      mkdir -p $out/lib/firefox/browser/defaults/preferences
      cp ${firefox-userchromejs}/installation-folder/config.js $out/lib/firefox/config.js
      cp ${firefox-userchromejs}/installation-folder/config-prefs.js $out/lib/firefox/browser/defaults/preferences/config-prefs.js
    '';
  });
in
{
  # Custom userChrome.js scripts
  home.file.".mozilla/firefox/dev-edition-default/chrome/mouseGestures" = {
    source = "${firefox-userchromejs}/chrome/mouseGestures";
    recursive = true;
  };
  home.file.".mozilla/firefox/dev-edition-default/chrome/mouseGestures.uc.js".source = ./mouseGestures.uc.js;

  # Custom theme
  home.file.".mozilla/firefox/dev-edition-default/chrome" = {
    recursive = true;
    source = "${firefox-gnome-theme}";
  };
  home.file.".mozilla/firefox/dev-edition-default/chrome/customChrome.css".source = ./customChrome.css;
  # home.file.".mozilla/firefox/dev-edition-default/chrome/theme/colors/dark.css".source = firefox-gnome-dark;

  programs.firefox = {
    enable = true;
    package = pkgs.wrapFirefox firefoxPackage {

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
        SearchEngines.Default = "DuckDuckGo";

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

          # Integration with KDE / Hyprland / GNOME
          # "gsconnect@andyholmes.github.io" = lib.optionalAttrs (lib.elem pkgs.gnomeExtensions.gsconnect config.home.packages) {
          #   installation_mode = "force_installed";
          #   install_url = "https://addons.mozilla.org/firefox/downloads/latest/gsconnect/latest.xpi";
          # };
          "plasma-browser-integration@kde.org" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/plasma-integration/latest.xpi";
          };

          # Gnome Shell Integration
          # "chrome-gnome-shell@gnome.org" = lib.optionalAttrs (lib.elem pkgs.gnomeExtensions.gsconnect config.home.packages) {
          #   installation_mode = "force_installed";
          #   install_url = "https://addons.mozilla.org/firefox/downloads/latest/gnome-shell-integration/latest.xpi";
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

          # Legacy Extensions
          "advancedlocationbar@veg.by" = {
            installation_mode = "force_installed";
            install_url = "file:/${./AdvancedLocationbar2_1.2.1.7.xpi}";
          };
          "backtrack@byalexv.co.uk" = {
            installation_mode = "force_installed";
            install_url = "file:/${./BackTrack.xpi}";
          };
          # Tab Mix Plus
          # "{dc572301-7619-498c-a57d-39143191b318}"
        };
      };
    };
    profiles = {
      dev-edition-default = {
        id = 0;
        isDefault = true;
        extraConfig = builtins.fetchurl
          {
            url = "https://raw.githubusercontent.com/yokoffing/Betterfox/4e44dc28202cda4b0b92401157839bf511dfceb3/user.js";
            sha256 = "1islaj99psf20n8f072g84rni32l5lxh53dwg3mlc05h3k5n7i6j";
          } + ''
          user_pref("svg.context-properties.content.enabled", true);
          user_pref("gnomeTheme.extensions.tabCenterReborn", true);
        '';
      };
    };
  };
}
