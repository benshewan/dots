{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.night-sky.programs.firefox;

  # Name of firefox profile (P.S. should be "default" in regular firefox and "dev-edition-default" for firefox dev edition)
  profile = "dev-edition-default";

  userchromejs-loader = pkgs.fetchFromGitHub {
    owner = "MrOtherGuy";
    repo = "fx-autoconfig";
    rev = "849602523e2a7fe7747dd964cc028e54078a5247";
    sha256 = "sha256-ibtYuRv21s4T+PbV0o3jRAuG/6mlaLzwWhkEivL1sho=";
  };

  legacyfox-loader = pkgs.fetchFromGitHub {
    owner = "girst";
    repo = "LegacyFox-mirror-of-git.gir.st";
    rev = "f732e438a6d8e75ce22c28c43878ca5e3effcadd";
    sha256 = "sha256-vCRIiYdl7t3I5asndJBjSRVFu9ADBfSEkyKdlgbMxww=";
  };

  merged-configjs =
    (
      (builtins.readFile "${userchromejs-loader}/program/config.js") + "\n"
    )
    + builtins.readFile "${legacyfox-loader}/config.js";

  firefox-package = (pkgs.firefox-devedition).overrideAttrs (oldAttrs: {
    # Add support for https://github.com/MrOtherGuy/fx-autoconfig
    buildCommand =
      (oldAttrs.buildCommand or "")
      + ''
        mkdir -p $out/lib/firefox-bin-${oldAttrs.version}/browser/defaults/preferences

        cp ${pkgs.writeText "config.js" merged-configjs} $out/lib/firefox-devedition/config.js

        cp -r ${legacyfox-loader}/legacy $out/lib/firefox-devedition/legacy
        cp ${legacyfox-loader}/legacy.manifest $out/lib/firefox-devedition/legacy.manifest

        cp ${userchromejs-loader}/program/defaults/pref/config-prefs.js $out/lib/firefox-devedition/browser/defaults/preferences/config-prefs.js
      '';
  });

  firefox-install-dir = "firefox";
in {
  options.night-sky.programs.firefox = {
    enable = lib.mkEnableOption "firefox";
  };
  imports = [
    ./custom-styles.nix
  ];

  config = lib.mkIf cfg.enable {
    # Move browser profile into ram disk
    services.psd.enable = true;
    services.psd.browsers = ["firefox"];

    home.file.".mozilla/firefox/${profile}/chrome/utils" = {
      recursive = true;
      source = "${userchromejs-loader}/profile/chrome/utils";
    };

    programs.firefox = {
      enable = true;
      package = firefox-package;
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
        # Extension Settings (Mostly just ublock supports it)
        "3rdparty".Extensions = import ./extensions/ublock.nix;
        # Firefox extensions
        ExtensionSettings = import ./extensions/extensions.nix;
      };
      profiles = {
        "${profile}" = {
          id = 0;
          isDefault = true;
          extraConfig =
            builtins.readFile
            (builtins.fetchurl
              {
                url = "https://raw.githubusercontent.com/yokoffing/Betterfox/9efeb601f60d7440b07c579fa47f047c83d2352d/user.js";
                sha256 = "sha256:10whisjgkiqk5qj0ppvmcdwfyrjq2hn04c4g00j9v9qry7apj2pv";
              })
            # Overrides
            + builtins.readFile ./user.js;
        };
      };
    };
  };
}
