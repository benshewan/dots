_: {
  flake.modules.homeManager."programs/firefox" = {
    pkgs,
    lib,
    config,
    ...
  }: let
    # Name of firefox profile (P.S. should be "default" in regular firefox and "dev-edition-default" for firefox dev edition)
    profile = "dev-edition-default";

    # Sidebery's moz-extension uuid, from extensions.webextensions.uuids in
    # about:config (key = sidebery's AMO id {3c078156-979c-498b-8990-85f7987dd929}).
    # Stable per profile; re-check there if sidebery is ever reinstalled.
    sideberyUuid = "9a1f69e0-57fa-4290-9010-be184ed86755";

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

    # Themed sidebery css with !important appended to every declaration that does not
    # have it yet (user-!important beats sidebery's own author-level styles).
    # NOTE: this gets inlined into userContent.css as text, NOT @import'ed - firefox
    # rejects @import targets whose real path lies outside the profile dir, so imports
    # through home-manager store symlinks silently never load.
    sideberyOverrideCss = pkgs.runCommand "sidebery-important.css" {} ''
      # append !important to every declaration that does not have it yet
      ${pkgs.perl}/bin/perl -0777 -pe 's{([^;{}]+:[^;{}]+)(;)}{$1 =~ /!important\s*$/ ? "$1$2" : "$1 !important;"}ge' \
        ${pkgs.writeText "sidebery-themed.css" themedSidebery} > $out
    '';

    # userContent.css with all of DownToneUI's content styles inlined (no @import -
    # see note above) plus our sidebery theming, scoped to sidebery's extension page.
    userContentCss =
      builtins.concatStringsSep "\n" [
        (builtins.readFile "${DownToneUI-firefox-theme}/chrome/DownToneUI/_globals.css")
        (builtins.readFile "${DownToneUI-firefox-theme}/chrome/DownToneUI/theme_about.css")
        (builtins.readFile "${DownToneUI-firefox-theme}/chrome/DownToneUI/theme_extern.css")
        (builtins.readFile "${DownToneUI-firefox-theme}/chrome/DownToneUI/theme_scrollbar.css")
        ''
          /* Your own customizations */
          * {
            --dtui-theme-color-scheme: ${colorScheme};
            --dtui-theme-main-color: ${rgbTriplet "base00"};
            --dtui-theme-secondary-color: ${rgbTriplet "base01"};
            --dtui-theme-accent-color: ${rgbTriplet "base0D"};
            --dtui-theme-accent-high-contrast: ${accentHighContrast};
            --dtui-theme-text-color: ${rgbTriplet "base05"};
          }

          /* Sidebery theming */
          @-moz-document url-prefix("moz-extension://${sideberyUuid}/") {
        ''
        (builtins.readFile sideberyOverrideCss)
        "}"
      ];

    # DownToneUI chrome dir minus userContent.css (we generate that one ourselves,
    # inlined - see note above).
    downtoneChrome = pkgs.runCommand "downtone-chrome" {} ''
      cp -r ${DownToneUI-firefox-theme}/chrome $out
      chmod -R u+w $out
      rm -f $out/userContent.css
    '';

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
      source = "${downtoneChrome}";
    };
    home.file.".config/mozilla/firefox/${profile}/chrome/userContent.css".text = userContentCss;
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
