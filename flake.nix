{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    spicetify-nix.url = "github:the-argus/spicetify-nix";
    flatpaks.url = "github:GermanBread/declarative-flatpak/fb31283f55f06b489f2baf920201e8eb73c9a0d3";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { self, nixpkgs, nur, home-manager, ... }@inputs:
    let
      userDescription = "Ben Shewan";
      username = "ben";
      system = "x86_64-linux";
      home_profile = "ben";
      flake_path = "/home/${username}/.nix";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations = {
        "${username}" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit username userDescription flake_path inputs; };
          modules = [
            ./users/${home_profile}
            # Pin registry to flake
            { nix.registry.nixpkgs.flake = nixpkgs; }
            # Pin channel to flake 
            { home.sessionVariables.NIX_PATH = "nixpkgs=nixpkgs=flake:nixpkgs$\{NIX_PATH:+:$NIX_PATH}"; }
            # Enables support for NUR packages
            { nixpkgs.overlays = [ nur.overlay ]; }
          ];
        };
      };
      nixosConfigurations = {
        sirius = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit username userDescription flake_path inputs; };
          modules = [
            ./systems/sirius
            { nixpkgs.overlays = [ nur.overlay ]; }
            { nix.registry.nixpkgs.flake = nixpkgs; }
            { nix.nixPath = [ "nixpkgs=configflake:nixpkgs" ]; }
          ];
        };
      };
    };
}
