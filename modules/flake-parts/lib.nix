{
  config,
  lib,
  ...
}: let
  # Generic factory to create dendritic pattern path resolvers.
  # It wraps string module paths into an attribute set with a unique `key`
  # to ensure proper deduplication during Nix module evaluation.
  mkResolver = namespace: prefix:
    builtins.map (
      m:
        if builtins.isString m
        then {
          key = "dendritic-${prefix}-${m}";
          imports = [config.flake.modules.${namespace}.${m}];
        }
        else m
    );

  # Pre-bake our specific path resolvers using the factory
  resolveNix = mkResolver "nixos" "nixos";
  resolveHm = mkResolver "homeManager" "hm";
  resolveDarwin = mkResolver "darwin" "darwin";
in {
  config.flake.lib = {
    # Resolve NixOS module paths
    # Usage: imports = config.flake.lib.resolveNix [ "presets/server" "secrets" ../../hardware.nix ];
    inherit resolveNix;

    # Resolve Home Manager module paths
    # Usage: home-manager.users.username.imports = config.flake.lib.resolveHm [ "users" "dotfiles" ];
    inherit resolveHm;

    # Resolve Darwin module paths
    # Usage: imports = config.flake.lib.resolveDarwin [ "security" "homebrew" ];
    inherit resolveDarwin;

    # Dendritic pattern helpers for module path resolution
    # Takes a single list of modules and automatically distributes them
    # to NixOS, Darwin, and Home Manager based on their existence in the flake.
    resolve = modules: let
      # Helper to safely check if a string module exists in a given namespace
      hasModule = namespace: m: let
        mods = config.flake.modules or {};
      in
        builtins.isString m && builtins.hasAttr m (mods.${namespace} or {});

      # Group modules by their target namespace based on existence
      nixosStr = builtins.filter (hasModule "nixos") modules;
      darwinStr = builtins.filter (hasModule "darwin") modules;
      hmStr = builtins.filter (hasModule "homeManager") modules;

      # Paths or other non-string imports default to standard system imports
      nonStrings = builtins.filter (m: !builtins.isString m) modules;

      # If a string module isn't found anywhere, pass it to system imports
      # so Nix can throw a standard, readable "attribute missing" evaluation error.
      missingStrings =
        builtins.filter (
          m:
            builtins.isString m
            && !(hasModule "nixos" m)
            && !(hasModule "darwin" m)
            && !(hasModule "homeManager" m)
        )
        modules;

      # Map the string names to their actual flake module values statically.
      # We reuse the resolvers defined above to enforce explicit keys for deduplication.
      resolvedNixos = resolveNix nixosStr;
      resolvedDarwin = resolveDarwin darwinStr;
      resolvedHm = resolveHm hmStr;

      # Apply Home Manager modules to the default user of the system
      defaultUser = config.flake.meta.user.username or "default";
    in
      [
        # 1. OS-Specific Modules (NixOS / Darwin)
        # We use an anonymous module function to detect the evaluation target.
        # This prevents Darwin modules from being injected into NixOS and vice versa.
        ({...} @ hostArgs: let
          # NixOS consistently injects `modulesPath` via specialArgs.
          isNixos = hostArgs ? modulesPath;
        in {
          imports =
            nonStrings
            ++ missingStrings
            ++ lib.optionals isNixos resolvedNixos
            ++ lib.optionals (!isNixos) resolvedDarwin;
        })
      ]
      ++ lib.optionals (resolvedHm != []) [
        # 2. Home Manager Modules
        # We append this as a completely static attribute set.
        # Keeping it outside the lambda prevents complex Home Manager submodule
        # evaluation duplicate errors that can arise when HM configs are wrapped dynamically.
        {
          home-manager.users.${defaultUser} = {
            imports = resolvedHm;
          };
        }
      ];

    ## Create a NixOS module option.
    ##
    ## ```nix
    ## lib.mkOpt nixpkgs.lib.types.str "My default" "Description of my option."
    ## ```
    ##
    #@ Type -> Any -> String
    mkOpt = type: default: description:
      lib.mkOption {inherit type default description;};
  };
}
