{pkgs ? import <nixpkgs> {}}: rec {
  # Packages with an actual source
  wisenet-viewer = pkgs.callPackage ./wisenet-viewer {};
  firefox-devedition-customjs = pkgs.callPackage ./firefox-devedition-customjs {};
  thorium = pkgs.callPackage ./thorium {};
  mercury = pkgs.callPackage ./mercury {};
  keylightd = pkgs.callPackage ./keylightd {};
}
