{
  description = "This is a LightDM Greeter made with Electron.js and node-gtk that allows to create web based themes with HTMl, CSS and JavaScript.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = import nixpkgs {
        inherit system;
        config.permittedInsecurePackages = [ "nodejs-16.20.1" "electron-16.2.3" ];
      };
      system = "x86_64-linux";
    in
    {
      packages.${system} = {
        nody-greeter = pkgs.callPackage ./. { };
        default = self.packages.${system}.nody-greeter;
      };
    };
}
