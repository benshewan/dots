{
  inputs,
  pkgs,
  system,
  ...
}: let
  zen-browser = inputs.zen-browser.packages."${system}".zen-browser-unwrapped;
  version = zen-browser.version;

  userchromejs-loader = pkgs.fetchFromGitHub {
    owner = "MrOtherGuy";
    repo = "fx-autoconfig";
    rev = "d597ff20583f6d948406a1ba1fbeb47bbe33a589";
    sha256 = "sha256-2rBvZauxGbo1//lbow7wntyLMZ9OJ17+YOssPgX8Q6s=";
  };

  legacyfox-loader = pkgs.fetchFromGitHub {
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
in
  pkgs.symlinkJoin {
    inherit (zen-browser) meta pname applicationName passthru version;
    paths = [inputs.zen-browser.packages."${system}".zen-browser-unwrapped];
    postBuild = ''
      mkdir -p $out/lib/zen-${version}/browser/defaults/preferences

      cp ${pkgs.writeText "config.js" merged-configjs} $out/lib/zen-${version}/config.js

      cp -r ${legacyfox-loader}/legacy $out/lib/zen-${version}/legacy
      cp ${legacyfox-loader}/legacy.manifest $out/lib/zen-${version}/legacy.manifest

      cp ${userchromejs-loader}/program/defaults/pref/config-prefs.js $out/lib/zen-${version}/browser/defaults/preferences/config-prefs.js
    '';
  }
