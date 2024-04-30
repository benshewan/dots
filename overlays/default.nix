# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
    firefox-devedition-unwrapped = prev.firefox-devedition-unwrapped.overrideAttrs (old: {
      postInstall = let
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
      in ''
        mkdir -p $out/lib/firefox/browser/defaults/preferences

        cp ${prev.writeText "config.js" merged-configjs} $out/lib/firefox/config.js

        cp -r ${legacyfox-loader}/legacy $out/lib/firefox/legacy
        cp ${legacyfox-loader}/legacy.manifest $out/lib/firefox/legacy.manifest

        cp ${userchromejs-loader}/program/defaults/pref/config-prefs.js $out/lib/firefox/browser/defaults/preferences/config-prefs.js
      '';
    });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
