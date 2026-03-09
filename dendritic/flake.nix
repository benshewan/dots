# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);

  inputs = {
    flake-file.url = "github:vic/flake-file";
    flake-parts.url = "github:hercules-ci/flake-parts";
    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix comma database
    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master"; # Easy hardware configuration for new machines
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    # Darwin features
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";
    # impermanence.url = "github:nix-community/impermanence";
    import-tree.url = "github:vic/import-tree";
    nix-darwin = {
      inputs.nixpkgs.follows = "nixpkgs-darwin";
      url = "github:LnL7/nix-darwin/nix-darwin-25.11";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Theming Stuff
    stylix.url = "github:danth/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    # Hyprland
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";

    hyprland-qtutils.url = "github:hyprwm/hyprland-qtutils";
    hyprland-qtutils.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-25.11-darwin";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    packages = {
      flake = false;
      url = "path:./packages";
    };
    pkgs-by-name-for-flake-parts.url = "github:drupol/pkgs-by-name-for-flake-parts";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions"; # alternate https://github.com/nix-community/nix4vscode
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";
  };
}
