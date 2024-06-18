{...}: final: prev: let
  userchromejs-loader = prev.fetchFromGitHub {
    owner = "MrOtherGuy";
    repo = "fx-autoconfig";
    rev = "d9133f188d4a037d9bf71aa208d1452d78adb25c";
    sha256 = "sha256-wJHcthpwoBi+T6NXkxwG+ePTHnIvut7Tr0UJDEOGL2U=";
  };
  legacyfox-loader = prev.fetchgit {
    url = "https://git.gir.st/LegacyFox.git";
    rev = "25664f0b2c3238704c7509cc661d52b6b5763599";
    sha256 = "sha256-USnJTUone62F8x8jJZCN0l67zTn5YicS3J4thPEwCRY=";
  };
  merged-configjs =
    (
      (builtins.readFile "${userchromejs-loader}/program/config.js") + "\n"
    )
    + builtins.readFile "${legacyfox-loader}/config.js";
  postInstall = ''
    mkdir -p $out/lib/firefox/browser/defaults/preferences

    cp ${prev.writeText "config.js" merged-configjs} $out/lib/firefox/config.js

    cp -r ${legacyfox-loader}/legacy $out/lib/firefox/legacy
    cp ${legacyfox-loader}/legacy.manifest $out/lib/firefox/legacy.manifest

    cp ${userchromejs-loader}/program/defaults/pref/config-prefs.js $out/lib/firefox/browser/defaults/preferences/config-prefs.js
  '';
in {
  firefox-unwrapped = prev.firefox-unwrapped.overrideAttrs (oldAttrs: {
    inherit postInstall;
  });

  firefox-devedition-unwrapped = prev.firefox-devedition-unwrapped.overrideAttrs (old: {
    inherit postInstall;
  });
}
