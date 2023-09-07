{
  description = "This  allows  users with a Hanwha Wisenet NVR system to remotely view and configure their cameras";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = import nixpkgs { inherit system; };
      system = "x86_64-linux";
    in
    {
      packages.${system} = {
        wisenet-viewer = pkgs.callPackage ./. { };
        default = self.packages.${system}.wisenet-viewer;
      };
    };
}