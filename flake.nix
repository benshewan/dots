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

  # Heavily inspired by the absoluely wonderful sourcehut:~misterio/nix-config
  outputs = { self, nixpkgs, nur, home-manager, ... }@inputs:
    let
      inherit (self) outputs;
      lib = nixpkgs.lib // home-manager.lib;
      username = "ben";
      userDescription = "Ben Shewan";
      flake-path = "/home/${username}/.nix";
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forEachSystem = f: lib.genAttrs systems (sys: f pkgsFor.${sys});
      pkgsFor = nixpkgs.legacyPackages;

      # Is this needed?
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
      inherit lib username userDescription flake-path;
      
      wallpapers = import "${flake-path}/wallpapers";

      nixosConfigurations = {
        # Main desktop
        sirius = lib.nixosSystem {
          modules = [ ./systems/sirius ] ++ defaultNixOSModules;
          specialArgs = { inherit inputs outputs; };
        };
        # Personal laptop
        corvus = lib.nixosSystem {
          modules = [ ./systems/corvus ] ++ defaultNixOSModules;
          specialArgs = { inherit inputs outputs; };
        };
        # Work desktop
        lepus = lib.nixosSystem {
          modules = [ ./systems/lepus ] ++ defaultNixOSModules;
          specialArgs = { inherit inputs outputs; };
        };
      };

      homeConfigurations = {
        "ben@generic" = lib.homeManagerConfiguration {
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./home/ben/global ] ++ defaultHomeManagerModules;
        };
        "ben@sirius" = lib.homeManagerConfiguration {
          modules = [ ./home/ben/sirius.nix ] ++ defaultHomeManagerModules;
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
        };
        "ben@corvus" = lib.homeManagerConfiguration {
          modules = [ ./home/ben/corvus.nix ] ++ defaultHomeManagerModules;
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
        };
        "ben@lepus" = lib.homeManagerConfiguration {
          modules = [ ./home/ben/lepus.nix ] ++ defaultHomeManagerModules;
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
        };
      };
    };
}
