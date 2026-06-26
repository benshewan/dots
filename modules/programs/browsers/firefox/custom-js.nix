_: {
  flake.modules.homeManager."programs/firefox" = {pkgs, ...}: let
    profile = "dev-edition-default";

    userchromejs-loader = pkgs.fetchFromGitHub {
      owner = "MrOtherGuy";
      repo = "fx-autoconfig";
      rev = "54f88294ea70f1d13ded482351da068d5f21c004";
      sha256 = "sha256-nO9OW5i6yjLJifZybBhvyZ6AlXlxnlaxNOhSHc8Yw1Y=";
    };

    aminomancer-scripts = pkgs.fetchFromGitHub {
      owner = "aminomancer";
      repo = "uc.css.js";
      rev = "88514013ddc375f4770f4a35d8d07a91d6dd7d8f";
      sha256 = "sha256-VrOgKNPJ3iTRqXqHYQz8UrZ6FpC1vHWwgy11AAfe4o8=";
    };

    legacyfox-loader = pkgs.fetchFromGitHub {
      owner = "girst";
      repo = "LegacyFox-mirror-of-git.gir.st";
      rev = "f732e438a6d8e75ce22c28c43878ca5e3effcadd";
      sha256 = "sha256-vCRIiYdl7t3I5asndJBjSRVFu9ADBfSEkyKdlgbMxww=";
    };

    merged-configjs = (builtins.readFile "${userchromejs-loader}/program/config.js" + "\n") + builtins.readFile "${legacyfox-loader}/config.js";

    firefox-package = (pkgs.firefox-devedition).overrideAttrs (oldAttrs: {
      # Add support for https://github.com/MrOtherGuy/fx-autoconfig
      buildCommand =
        (oldAttrs.buildCommand or "")
        + ''
          mkdir -p $out/lib/firefox-devedition/browser/defaults/preferences

          cp ${pkgs.writeText "config.js" merged-configjs} $out/lib/firefox-devedition/config.js

          cp -r ${legacyfox-loader}/legacy $out/lib/firefox-devedition/legacy
          cp ${legacyfox-loader}/legacy.manifest $out/lib/firefox-devedition/legacy.manifest

          cp ${userchromejs-loader}/program/defaults/pref/config-prefs.js $out/lib/firefox-devedition/defaults/pref/autoconfig.js
        '';
    });
  in {
    home.file.".config/mozilla/firefox/${profile}/chrome/utils" = {
      recursive = true;
      source = "${userchromejs-loader}/profile/chrome/utils";
      # source = pkgs.lib.cleanSourceWith {
      #   src = "${userchromejs-loader}/profile/chrome/utils";
      #   filter = path: type: baseNameOf path != "chrome.manifest";
      # };
    };

    # Make it so pressing CTRL+F again will close the findbar
    home.file.".config/mozilla/firefox/${profile}/chrome/JS/findbarMods.uc.js".source = "${aminomancer-scripts}/JS/findbarMods.uc.js";
    # Allow you to customize the url of the new tab page (works better then something like new tab override extension)
    home.file.".config/mozilla/firefox/${profile}/chrome/JS/newtab-customize.uc.js".source = ./custom-user-js/newtab-customize.uc.js;
    # Works like the old legacy backtrack extension, copies the history from the parent tab when opening something in a new tab
    # home.file.".config/mozilla/firefox/${profile}/chrome/JS/backtrack.uc.js".source = ./custom-user-js/backtrack.uc.js;

    programs.firefox.package = firefox-package;
  };
}
