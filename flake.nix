{
  outputs = {self, ...} @ inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;

      channels-config.allowUnfree = true;
      outputs-builder = channels: {
        formatter = channels.nixpkgs.alejandra;
      };

      snowfall = {
        namespace = "night-sky";
        meta = {
          name = "night-sky";
          title = "The Night Sky";
        };
      };

      overlays = with inputs; [
        snowfall-flake.overlays.default
        inputs.nix-vscode-extensions.overlays.default
      ];
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master"; # Easy hardware configuration for new machines
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    # nur.url = "github:nix-community/NUR"; # Community app support

    # encrypt secrets
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Nix comma database
    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    # Secure boot
    lanzaboote.url = "github:nix-community/lanzaboote";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";

    # Darwin features
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";

    # Use file structure routing to build this flake
    snowfall-lib.url = "github:snowfallorg/lib/dev";
    snowfall-lib.inputs.nixpkgs.follows = "nixpkgs";
    snowfall-flake.url = "github:snowfallorg/flake";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";

    hyprland-qtutils.url = "github:hyprwm/hyprland-qtutils";
    hyprland-qtutils.inputs.nixpkgs.follows = "nixpkgs";

    # Hyprland Plugins
    hyprsunset.url = "github:hyprwm/hyprsunset";
    hyprsunset.inputs.nixpkgs.follows = "nixpkgs";

    split-monitor-workspaces.url = "github:Duckonaut/split-monitor-workspaces";
    split-monitor-workspaces.inputs.hyprland.follows = "hyprland";

    # Theming Stuff
    stylix.url = "github:danth/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    stylix.inputs.home-manager.follows = "home-manager";

    kvlibadwaita.url = "github:MOIS3Y/KvLibadwaita";
    kvlibadwaita.inputs.nixpkgs.follows = "nixpkgs";

    # App configuration helpers
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions"; # alternate https://github.com/nix-community/nix4vscode
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    # KDE Configuration SUpport
    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Temporary patches
    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
  };
}
