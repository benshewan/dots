{
  description = "A fix for MongoDB-Compass in wayland enviroments";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs?ref=nixos-unstable";
    };
  };

  outputs = { self, nixpkgs }:
  let
    pkgs = import nixpkgs {inherit system;};
    system = "x86_64-linux";
  in
  {

    packages.${system} = {
#       mongodb-compass = pkgs.callPackage ./. {};
      default = pkgs.symlinkJoin {
        name = "mongodb-desktop";
        paths = [ pkgs.mongodb-compass ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/mongodb-compass --enable-features=UseOzonePlatform --ozone-platform=wayland --ignore-additional-command-line-flags
        '';
      };
    };

  };
}
