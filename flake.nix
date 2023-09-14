{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nur.url = "github:nix-community/NUR"; # Community app support
    # Home Manager modules
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix.url = "github:the-argus/spicetify-nix";
    nix-colors.url = "github:misterio77/nix-colors";
    flatpaks.url = "github:GermanBread/declarative-flatpak/fb31283f55f06b489f2baf920201e8eb73c9a0d3";
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
      flake-path = "/home/${username}/.nix";
      pkgs = nixpkgs.legacyPackages.${system};

      defaultNixOSModules = [
        { nix.registry.nixpkgs.flake = nixpkgs; }
        { nix.nixPath = [ "nixpkgs=configflake:nixpkgs" ]; }
        { nixpkgs.overlays = [ nur.overlay ]; }
      ];
      defaultHomeManagerModules = [
        { nix.registry.nixpkgs.flake = nixpkgs; }
        { home.sessionVariables.NIX_PATH = "nixpkgs=nixpkgs=flake:nixpkgs$\{NIX_PATH:+:$NIX_PATH}"; }
        { nixpkgs.overlays = [ nur.overlay ]; }
      ];
    in
    {
      homeConfigurations = {
        ben = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit username userDescription flake-path inputs; };
          modules = [ ./users/ben ] ++ defaultHomeManagerModules;
        };
      };
      nixosConfigurations = {
        sirius = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit username userDescription flake-path inputs; };
          modules = [ ./systems/sirius ] ++ defaultNixOSModules;
        };
        corvus = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit username userDescription flake-path inputs; };
          modules = [ ./systems/corvus ] ++ defaultNixOSModules;
        };
      };
    };
}
