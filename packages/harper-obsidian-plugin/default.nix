{pkgs, ...}: let
  version = "1.6.0"; # Update this to the desired version
  baseUrl = "https://github.com/Automattic/harper-obsidian-plugin/releases/download/${version}";

  # Fetch the individual files from the GitHub Release
  manifest = pkgs.fetchurl {
    url = "${baseUrl}/manifest.json";
    # Run `nix-prefetch-url` or set to lib.fakeSha256 to get the real hash
    hash = "sha256-OAC9kmWlDW27d1Mm+Wd8yJ++kgujpgzkh0HYzTkPQoo=";
  };

  mainJs = pkgs.fetchurl {
    url = "${baseUrl}/main.js";
    hash = "sha256-pdODDlBMQmCefgmdmXmLAkM/Gu6eYaiKK9pVNegN/Mw=";
  };
  # styles = pkgs.fetchurl {
  #   url = "${baseUrl}/styles.css";
  #   hash = "";
  # };
in
  pkgs.stdenv.mkDerivation {
    pname = "harper-obsidian-plugin";
    inherit version;

    # We don't need a source folder because we are downloading specific files
    dontUnpack = true;

    installPhase = ''
      mkdir -p $out

      # Copy the fetched artifacts to the output directory
      cp ${manifest} $out/manifest.json
      cp ${mainJs} $out/main.js
    '';

    meta = with pkgs.lib; {
      description = "The Grammar Checker for Developers";
      homepage = "https://github.com/elijah-potter/harper";
      license = licenses.asl20;
      maintainers = [];
      platforms = platforms.all;
    };
  }
