{...}: final: prev: {
  firefox-unwrapped = prev.firefox-unwrapped.overrideAttrs (oldAttrs: {
    postInstall = let
      userchromejs-loader = prev.fetchFromGitHub {
        owner = "MrOtherGuy";
        repo = "fx-autoconfig";
        rev = "d9133f188d4a037d9bf71aa208d1452d78adb25c";
        sha256 = "sha256-wJHcthpwoBi+T6NXkxwG+ePTHnIvut7Tr0UJDEOGL2U=";
      };
    in ''
      mkdir -p $out/lib/firefox/browser/defaults/preferences
      cp ${userchromejs-loader}/program/config.js $out/lib/firefox/config.js
      cp ${userchromejs-loader}/program/defaults/pref/config-prefs.js $out/lib/firefox/browser/defaults/preferences/config-prefs.js
    '';
  });
}
