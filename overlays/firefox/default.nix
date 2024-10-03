{...}: final: prev: let
  userchromejs-loader = prev.fetchFromGitHub {
    owner = "MrOtherGuy";
    repo = "fx-autoconfig";
    rev = "d9133f188d4a037d9bf71aa208d1452d78adb25c";
    sha256 = "sha256-wJHcthpwoBi+T6NXkxwG+ePTHnIvut7Tr0UJDEOGL2U=";
  };
  legacyfox-loader = prev.fetchFromGitHub {
    owner = "girst";
    repo = "LegacyFox-mirror-of-git.gir.st";
    rev = "312a791ae03bddd725dee063344801f959cfe44d";
    sha256 = "sha256-3XtqRa07GjA9/LlZw/b2eVZZa7/akaVo3kzRUYBg9xY=";
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
