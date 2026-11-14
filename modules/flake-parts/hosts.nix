{
  inputs,
  lib,
  config,
  ...
}: let
  prefix = "hosts/";

  # Helper to build a host configuration (works for both NixOS and Darwin)
  mkHostConfig = hostType: name: hostModule: let
    hostId = lib.removePrefix prefix name;

    # Per-host defaults from flake.meta.hosts (a list keyed by name)
    hostMeta = lib.findFirst (h: h.name == hostId) {} config.flake.meta.hosts;

    # Machine-scoped modules registered as machines/<hostId>/* attach to that
    # host automatically, so host definitions never import them by hand.
    machinePrefix = "machines/${hostId}/";
    machineModules =
      lib.attrValues
      (lib.filterAttrs (n: _: lib.hasPrefix machinePrefix n) (
        if hostType == "nixos"
        then config.flake.modules.nixos
        else config.flake.modules.darwin or {}
      ));

    # hardware-configuration.nix stays a raw nixos-generate-config module so
    # nixos-anywhere --generate-hardware-config can overwrite it verbatim; it
    # is imported by path here (and excluded from the import-tree scan).
    hardwareConfig = ../../machines/${hostId}/hardware-configuration.nix;

    # Platform-specific defaults
    platformDefaults =
      {
        nixos = {
          defaultSystem = "x86_64-linux";
          builder = inputs.nixpkgs.lib.nixosSystem;
          homeManagerModule = inputs.home-manager.nixosModules.home-manager;
        };
        darwin = {
          defaultSystem = "aarch64-darwin";
          builder = inputs.nix-darwin.lib.darwinSystem;
          homeManagerModule = inputs.home-manager.darwinModules.home-manager;
        };
      }.${
        hostType
      };

    # Use the first system from config.systems that matches the platform type
    # For darwin hosts, prefer darwin systems; for nixos hosts, prefer linux systems
    evalSystem =
      if (config ? systems) && (config.systems != [])
      then let
        isDarwinSystem = sys: lib.hasSuffix "-darwin" sys;
        matchingSystems = lib.filter (sys: (hostType == "darwin") == (isDarwinSystem sys)) config.systems;
      in
        if matchingSystems != []
        then builtins.head matchingSystems
        else platformDefaults.defaultSystem
      else platformDefaults.defaultSystem;
  in {
    name = hostId;
    value = platformDefaults.builder {
      system = evalSystem;
      modules =
        [
          hostModule
          platformDefaults.homeManagerModule
          {
            networking.hostName = hostId;
            time.timeZone = lib.mkDefault hostMeta.timezone;
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
            };
          }
        ]
        ++ machineModules
        ++ lib.optional (builtins.pathExists hardwareConfig) hardwareConfig;
    };
  };

  # Collect host modules from both namespaces
  nixosHostModules = lib.filterAttrs (name: _: lib.hasPrefix prefix name) config.flake.modules.nixos;
  darwinHostModules = lib.filterAttrs (name: _: lib.hasPrefix prefix name) (
    config.flake.modules.darwin or {}
  );
in {
  flake = {
    nixosConfigurations = lib.mapAttrs' (mkHostConfig "nixos") nixosHostModules;
    darwinConfigurations = lib.mapAttrs' (mkHostConfig "darwin") darwinHostModules;
  };
}
