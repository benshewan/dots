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
      rev = "4c039a5c7a7b657d4e5146a6ca6d81942ae1bd0b";
      hash = "sha256-HMMM4aKfDPx8m5IoTc4dCh01ZaBf0upEXPEjIcFsa4s=";
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

  # Custom theme
  home.file.".mozilla/firefox/${profile}/chrome/userChrome.css".source = "${firefox-gnome-theme}/userChrome.css";
  home.file.".mozilla/firefox/${profile}/chrome/userContent.css".source = "${firefox-gnome-theme}/userContent.css";
  home.file.".mozilla/firefox/${profile}/chrome/theme" = {
    recursive = true;
    source = "${firefox-gnome-theme}/theme";
  };
  home.file.".mozilla/firefox/${profile}/chrome/theme/colors".enable = false;
  home.file.".mozilla/firefox/${profile}/chrome/customChrome.css".source = ./customChrome.css;
  home.file.".mozilla/firefox/${profile}/chrome/theme/colors/dark.css".source = firefox-gnome-dark;

  # Stylix support
  stylix.targets.firefox.profileNames = [profile];

  programs.firefox = {
    enable = true;
    package = pkgs.wrapFirefox pkgs.firefox-devedition-unwrapped {
      # Enable Native Messaging Hosts
      nativeMessagingHosts =
        []
        ++ lib.optional config.services.kdeconnect.enable pkgs.plasma-browser-integration;

      # with pkgs; [
      #   plasma-browser-integration
      #   # pkgs.gnomeExtensions.gsconnect
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
