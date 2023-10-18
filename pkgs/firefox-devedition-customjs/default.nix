# This little bit of magic comes courtesy of https://stackoverflow.com/questions/68523367/in-nixpkgs-how-do-i-override-files-of-a-package-without-recompilation
# Example usage:
#
# Build the package:
#     nix-build --no-out-link change-file-after-build-example.nix
# See our replacement worked:
#     $ $(nix-build --no-out-link change-file-after-build-example.nix)/share/git/contrib/fast-import/git-import.sh
#     USAGE: git-import branch import-message
{
  pkgs ? import <nixpkgs> {},
  lib ? pkgs.lib,
  fetchFromGitHub,
}: let
  originalPackage = pkgs.firefox-devedition-unwrapped;

  src = fetchFromGitHub {
    owner = "xiaoxiaoflood";
    repo = "firefox-scripts";
    rev = "b013243f1916576166a02d816651c2cc6416f63e";
    sha256 = "sha256-Zp1pRMqgAM3Xh3JCkAC0hWp2Gl2phkyAwJ8KB2tA9jE=";
  };
  # We use `overrideAttrs` instead of defining a new `mkDerivation` to keep
  # the original package's `output`, `passthru`, and so on.
  firefox-devedition-customjs = originalPackage.overrideAttrs (old: {
    name = "firefox-devedition-customjs";

    # Using `buildCommand` replaces the original packages build phases.
    buildCommand = ''
      set -euo pipefail

      ${
        # Copy original files, for each split-output (`out`, `dev` etc.).
        # E.g. `${package.dev}` to `$dev`, and so on. If none, just "out".
        # Symlink all files from the original package to here (`cp -rs`),
        # to save disk space.
        # We could alternatiively also copy (`cp -a --no-preserve=mode`).
        lib.concatStringsSep "\n"
        (
          map
          (
            outputName: ''
              echo "Copying output ${outputName}"
              set -x
              cp -rs --no-preserve=mode "${originalPackage.${outputName}}" "''$${outputName}"
              set +x
            ''
          )
          (old.outputs or ["out"])
        )
      }
      mkdir

      # Example change:
      # Change `usage:` to `USAGE:` in a shell script.
      # Make the file to be not a symlink by full copying using `install` first.
      # This also makes it writable (files in the nix store have `chmod -w`).
      # install -v "${originalPackage}"/share/git/contrib/fast-import/git-import.sh "$out"/share/git/contrib/fast-import/git-import.sh
      # sed -i -e 's/usage:/USAGE:/g' "$out"/share/git/contrib/fast-import/git-import.sh
    '';
    postInstall = ''
      mkdir -p $out/lib/firefox/browser/defaults/preferences
       cp ${src}/installation-folder/config.js $out/lib/firefox/config.js
       cp ${src}/installation-folder/config-prefs.js $out/lib/firefox/browser/defaults/preferences/config-prefs.js
    '';
  });
in
  firefox-devedition-customjs
