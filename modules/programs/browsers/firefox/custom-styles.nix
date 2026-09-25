_: {
  flake.modules.homeManager."programs/firefox" = {
    pkgs,
    lib,
    config,
    ...
  }: let
    # Name of firefox profile (P.S. should be "default" in regular firefox and "dev-edition-default" for firefox dev edition)
    profile = "dev-edition-default";

    # Sidebery's AMO extension id (firefox derives the moz-extension uuid from it)
    sideberyId = "{3c078156-979c-498b-8990-85f7987dd929}";

    c = config.lib.stylix.colors;

    chan = base: suffix: c."${base}-${suffix}";
    rgbTriplet = base: "${chan base "rgb-r"}, ${chan base "rgb-g"}, ${chan base "rgb-b"}";

    brightness = base: let
      r = lib.toInt (chan base "rgb-r");
      g = lib.toInt (chan base "rgb-g");
      b = lib.toInt (chan base "rgb-b");
    in r * 299 + g * 587 + b * 114;

    isDark = (brightness "base00") < (brightness "base05");
    colorScheme = if isDark then "dark" else "light";
    accentHighContrast =
      if isDark
      then "color-mix(in srgb, white 30%, rgb(${rgbTriplet "base0D"}))"
      else "color-mix(in srgb, black 30%, rgb(${rgbTriplet "base0D"}))";

    themedSidebery =
      lib.replaceStrings
      [
        "--dtui-theme-color-scheme: dark;"
        "--dtui-theme-main-color: 30, 34, 44;"
        "--dtui-theme-secondary-color: 35, 40, 52;"
        "--dtui-theme-accent-color: 58, 104, 175;"
        "--dtui-theme-text-color: 240, 240, 240;"
        "--dtui-theme-accent-high-contrast: hsl(219, 100.0%, 77.5%);"
      ]
      [
        "--dtui-theme-color-scheme: ${colorScheme};"
        "--dtui-theme-main-color: ${rgbTriplet "base00"};"
        "--dtui-theme-secondary-color: ${rgbTriplet "base01"};"
        "--dtui-theme-accent-color: ${rgbTriplet "base0D"};"
        "--dtui-theme-text-color: ${rgbTriplet "base05"};"
        "--dtui-theme-accent-high-contrast: ${accentHighContrast};"
      ]
      (builtins.readFile "${DownToneUI-firefox-theme}/sidebery/sidebery_style.css");

    ff-ultima-theme = pkgs.fetchFromGitHub {
      owner = "soulhotel";
      repo = "FF-ULTIMA";
      rev = "f99ca1cbfee282d7d12d155d86c4e85a7c87b91a";
      sha256 = "sha256-ys0hr+WMldEq+wyPNJ584US7JKoaSwTcHaS5Dk7u/DI=";
    };

    natsumi-theme = pkgs.fetchFromGitHub {
      owner = "greeeen-dev";
      repo = "natsumi-browser";
      rev = "4d1596553ad00c4576b6c0a5be71775798de20e6";
      sha256 = "sha256-BzeUNg3aY7uHubv2ackuH01AAeiyCXnXMBNtfBdvcFY=";
    };


    DownToneUI-firefox-theme = pkgs.fetchFromGitHub {
      owner = "oviung";
      repo = "DownToneUI-Firefox";
      rev = "f5502e56cc06e24a5238b70351780bee1b000598";
      sha256 = "sha256-IjIkF1kdWSP4ytjh36jdpVlQu2MRtTP57GVcz5+E5qc=";
    };

    firefox-second-sidebar = pkgs.fetchFromGitHub {
      owner = "aminought";
      repo = "firefox-second-sidebar";
      rev = "95d4f2870daa02b0a209c5583531dbf3a5ffd346";
      sha256 = "sha256-aJs74EqAVMJBPS6ox2V7S9Vp47PoHlGbBuF5DBWqwiI=";
    };
  in {

    home.file.".config/mozilla/firefox/${profile}/chrome" = {
      recursive = true;
      source = "${DownToneUI-firefox-theme}/chrome";
    };
    home.file.".config/mozilla/firefox/${profile}/chrome/DownToneUI/override_globals.css".text = ''
      * {
        --dtui-theme-color-scheme: ${colorScheme};
        --dtui-theme-main-color: ${rgbTriplet "base00"};
        --dtui-theme-secondary-color: ${rgbTriplet "base01"};
        --dtui-theme-accent-color: ${rgbTriplet "base0D"};
        --dtui-theme-accent-high-contrast: ${accentHighContrast};
        --dtui-theme-text-color: ${rgbTriplet "base05"};
      }
    '';
    home.file.".config/mozilla/firefox/${profile}/chrome/JS/sidebery-theme.uc.js".text = ''
      // ==UserScript==
      // @name           sidebery-theme
      // @description    Inject themed DownToneUI Sidebery CSS as an agent sheet
      // @onlyonce
      // ==/UserScript==

      (function () {
        const sss = Cc["@mozilla.org/content/style-sheet-service;1"].getService(Ci.nsIStyleSheetService);

        // Since firefox 155 @-moz-document conditions of add-on documents are matched against
        // the extension's base url (moz-extension://<uuid>/) instead of the page url, so match
        // that prefix - url-prefix also still matches the full page url (firefox <= 154).
        let uuid = null;
        try {
          uuid = JSON.parse(Services.prefs.getStringPref("extensions.webextensions.uuids", "{}"))["${sideberyId}"];
        } catch (e) {}
        if (!uuid) {
          console.warn("sidebery-theme: Sidebery's moz-extension uuid is unknown, falling back to a broad @-moz-document pattern");
        }
        const scope = uuid
          ? 'url-prefix("moz-extension://' + uuid + '/")'
          : 'regexp("moz-extension://.*")';

        let css = '@-moz-document ' + scope + ' {\n' + ${builtins.toJSON themedSidebery} + '\n}';
        css = css.replace(/([^;{}]+:[^;{}]+)(;)/g, (m, d, e) =>
          /!important\s*$/.test(d) ? m : d + " !important" + e
        );
        const uri = Services.io.newURI("data:text/css;charset=utf-8," + encodeURIComponent(css));

        const register = () => {
          if (sss.sheetRegistered(uri, sss.AGENT_SHEET)) {
            sss.unregisterSheet(uri, sss.AGENT_SHEET);
          }
          sss.loadAndRegisterSheet(uri, sss.AGENT_SHEET);
        };

        register();
        // Agent sheets are only sent to content processes that already exist when they are
        // registered, so sidebery's own process (created when the sidebar/panel loads) misses
        // the sheet. Re-registering whenever a content process comes up delivers it there too.
        Services.obs.addObserver((subject, topic) => {
          if (topic === "ipc:content-created") {
            try {
              register();
            } catch (e) {}
          }
        }, "ipc:content-created");
      })();
    '';

    # FF-Ultima
    # -------------------------------------------------------------------
    # home.file.".config/mozilla/firefox/${profile}/chrome/userChrome.css".source = "${ff-ultima-theme}/userChrome.css";
    # home.file.".config/mozilla/firefox/${profile}/chrome/userContent.css".source = "${ff-ultima-theme}/userContent.css";
    # home.file.".config/mozilla/firefox/${profile}/chrome/theme" = {
    #   recursive = true;
    #   source = "${ff-ultima-theme}/theme";
    # };

    # Natsumi
    # -------------------------------------------------------------------
    # home.file.".config/mozilla/firefox/${profile}/chrome/userChrome.css".source = "${natsumi-theme}/userChrome.css";
    # home.file.".config/mozilla/firefox/${profile}/chrome/userContent.css".source = "${natsumi-theme}/userContent.css";
    # home.file.".config/mozilla/firefox/${profile}/chrome/natsumi" = {
    #   recursive = true;
    #   source = "${natsumi-theme}/natsumi";
    # };
    # home.file.".config/mozilla/firefox/${profile}/chrome/utils/chrome.manifest".text = ''
    #   content userchromejs ./
    #   content userscripts ../natsumi/scripts/
    #   skin userstyles classic/1.0 ../CSS/
    #   content userchrome ../resources/
    #   content natsumi ../natsumi/
    #   content natsumi-icons ../natsumi/icons/
    # '';

    # Firefox sidebar
    # -------------------------------------------------------------------
    # home.file.".config/mozilla/firefox/${profile}/chrome/JS" = {
    #   recursive = true;
    #   source = "${firefox-second-sidebar}/src";
    # };
  };
}
