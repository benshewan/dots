{...}: let
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
in {
  # NixOS
  flake.modules.nixos.system = {
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
