{ pkgs ? import <nixpkgs> { } }: rec {

  # Packages with an actual source
  wisenet-viewer = pkgs.callPackage ./wisenet-viewer { };
}
