{inputs, ...}: {
  flake-file.inputs = {
    maki = {
      url = "github:tontinton/maki";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.homeManager."programs/maki" = {
    pkgs,
    lib,
    ...
  }: {
    home.packages = [inputs.maki.packages.${pkgs.stdenv.hostPlatform.system}.default];
  };
}
