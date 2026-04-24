{
  inputs,
  lib,
  ...
} @ args: let
  # Shared Cachix configuration for both NixOS and Darwin
  sharedCachixConfig = {
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # Shared nix settings for both NixOS and Darwin
  sharedNixSettings =
    {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
      use-xdg-base-directories = true;
    }
    // sharedCachixConfig;

  # NixOS-specific nix settings
  nixosNixSettings =
    sharedNixSettings
    // {
      auto-optimise-store = true;
    };

  # Shared home-manager config
  sharedHomeManagerConfig = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
  };

  # Overlays
  # ------------------------------
  allFiles = lib.filesystem.listFilesRecursive ../../overlays;

  nixFiles = builtins.filter (file: lib.hasSuffix ".nix" (builtins.toString file)) allFiles;

  dynamicOverlays = map (file: import file args) nixFiles;
in {
  flake-file.inputs = {
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:LnL7/nix-darwin";

    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-25.11";
    # mac-app-util.url = "github:hraban/mac-app-util";
  };

  # NixOS
  flake.modules.nixos.system = {
    imports = [inputs.determinate.nixosModules.default];
    programs.nix-ld.enable = true;
    nixpkgs.config.allowUnfree = true;

    nix = {
      settings =
        nixosNixSettings
        // {
          trusted-users = [
            "root"
            "@wheel"
          ];
        };

      # Garbage collection is handled by nh
      gc.automatic = false;
      optimise.automatic = true;
      channel.enable = false;
    };
    #  add flake parts overlay
    nixpkgs.overlays = [inputs.self.overlays.default] ++ dynamicOverlays;
    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).

    system.stateVersion = "23.05"; # Did you read the comment?

    home-manager = sharedHomeManagerConfig;
  };

  # Darwin
  flake.modules.darwin.system = {
    nixpkgs.config.allowUnfree = true;

    nix = {
      settings =
        sharedNixSettings
        // {
          trusted-users = [
            "root"
            "@admin"
          ];
        };

      # Garbage collection is handled by nh
      gc.automatic = false;
      optimise.automatic = true;
    };

    home-manager = sharedHomeManagerConfig;
  };
}
