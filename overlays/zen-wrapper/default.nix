{inputs, ...}: final: prev: let
  userchromejs-loader = prev.fetchFromGitHub {
    owner = "MrOtherGuy";
    repo = "fx-autoconfig";
    rev = "d597ff20583f6d948406a1ba1fbeb47bbe33a589";
    sha256 = "sha256-2rBvZauxGbo1//lbow7wntyLMZ9OJ17+YOssPgX8Q6s=";
  };

  legacyfox-loader = prev.fetchFromGitHub {
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
in {
  zen-browser-unwrapped = inputs.zen-browser.packages."${prev.system}".zen-browser-unwrapped.overrideAttrs (oldAttrs: {
    installPhase =
      oldAttrs.installPhase
      + ''
        mkdir -p $out/lib/zen-${oldAttrs.version}/browser/defaults/preferences

        cp ${prev.writeText "config.js" merged-configjs} $out/lib/zen-${oldAttrs.version}/config.js

        cp -r ${legacyfox-loader}/legacy $out/lib/zen-${oldAttrs.version}/legacy
        cp ${legacyfox-loader}/legacy.manifest $out/lib/zen-${oldAttrs.version}/legacy.manifest

        cp ${userchromejs-loader}/program/defaults/pref/config-prefs.js $out/lib/zen-${oldAttrs.version}/browser/defaults/preferences/config-prefs.js
      '';
  });
}
