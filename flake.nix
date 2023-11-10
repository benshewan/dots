{
  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master"; # Easy hardware configuration for new machines
    nur.url = "github:nix-community/NUR"; # Community app support
    # Home Manager modules
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-colors.url = "github:misterio77/nix-colors";
    spicetify-nix.url = "github:the-argus/spicetify-nix";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions"; # alternate https://github.com/nix-community/nix4vscode
    flatpaks.url = "github:GermanBread/declarative-flatpak/fb31283f55f06b489f2baf920201e8eb73c9a0d3";
    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  # Heavily inspired by the absoluely wonderful sourcehut:~misterio/nix-config
  outputs = {
    self,
    nixpkgs,
    nur,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
    lib = nixpkgs.lib // home-manager.lib;
    username = "ben";
    userDescription = "Ben Shewan";
    flake-path = "/home/${username}/.nix";
    systems = ["x86_64-linux" "aarch64-linux"];
    forEachSystem = f: lib.genAttrs systems (sys: f pkgsFor.${sys});
    pkgsFor = nixpkgs.legacyPackages;
  in {
    inherit lib username userDescription flake-path;

    nixosModules = import ./modules/nixos;
    homeManagerModules = import ./modules/home-manager;

    packages = forEachSystem (pkgs: import ./pkgs {inherit pkgs;});
    overlays = import ./overlays {inherit inputs;};

    wallpapers = import "${flake-path}/wallpapers";

    nixosConfigurations = {
      # Main desktop
      sirius = lib.nixosSystem {
        modules = [./systems/sirius];
        specialArgs = {inherit inputs outputs;};
      };
      # Personal laptop - Old Dell
      corvus = lib.nixosSystem {
        modules = [./systems/corvus];
        specialArgs = {inherit inputs outputs;};
      };
      # Work desktop
      lepus = lib.nixosSystem {
        modules = [./systems/lepus];
        specialArgs = {inherit inputs outputs;};
      };
      # Personal laptop - Framework 13 AMD
      navis = lib.nixosSystem {
        modules = [./systems/navis];
        specialArgs = {inherit inputs outputs;};
      };
    };

    homeConfigurations = {
      "ben@generic" = lib.homeManagerConfiguration {
        pkgs = pkgsFor.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [./home/ben/global];
      };
      "ben@sirius" = lib.homeManagerConfiguration {
        modules = [./home/ben/sirius.nix];
        pkgs = pkgsFor.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
      };
      "ben@corvus" = lib.homeManagerConfiguration {
        modules = [./home/ben/corvus.nix];
        pkgs = pkgsFor.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
      };
      "ben@lepus" = lib.homeManagerConfiguration {
        modules = [./home/ben/lepus.nix];
        pkgs = pkgsFor.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
      };
      "ben@navis" = lib.homeManagerConfiguration {
        modules = [./home/ben/navis.nix];
        pkgs = pkgsFor.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
      };
    };
  };
}
