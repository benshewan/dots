{inputs, ...}: {
  flake-file.inputs = {
    helium = {
      url = "github:schembriaiden/helium-browser-nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.homeManager."programs/helium" = {
    pkgs,
    lib,
    config,
    ...
  }: {
    home.packages = with pkgs; [inputs.helium.packages.${system}.default];
  };
}
