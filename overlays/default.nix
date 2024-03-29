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
    firefox-unwrapped = prev.firefox-unwrapped.overrideAttrs (old: {
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
