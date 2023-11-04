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
        firefox-userchromejs = prev.fetchFromGitHub {
          owner = "xiaoxiaoflood";
          repo = "firefox-scripts";
          rev = "b013243f1916576166a02d816651c2cc6416f63e";
          sha256 = "sha256-Zp1pRMqgAM3Xh3JCkAC0hWp2Gl2phkyAwJ8KB2tA9jE=";
        };
      in ''
        mkdir -p $out/lib/firefox/browser/defaults/preferences
        cp ${firefox-userchromejs}/installation-folder/config.js $out/lib/firefox/config.js
        cp ${firefox-userchromejs}/installation-folder/config-prefs.js $out/lib/firefox/browser/defaults/preferences/config-prefs.js
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
