{
  pkgs,
  config,
  lib,
  inputs,
  system,
  ...
}: let
  cfg = config.night-sky.programs.zen;
in {
  options.night-sky.programs.zen = {
    enable = lib.mkEnableOption "zen";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      (
        pkgs.wrapFirefox inputs.zen-browser.packages."${system}".zen-browser-unwrapped {
          pname = "zen-browser";
          nativeMessagingHosts =
            [pkgs.goldwarden]
            ++ lib.optional config.services.kdeconnect.enable pkgs.plasma-browser-integration;

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

            # Firefox extensions
            ExtensionSettings = import ./extensions.nix;
          };
        }
      )
    ];
  };
}
