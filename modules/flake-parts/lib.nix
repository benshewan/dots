{
  config,
  lib,
  ...
}: let
  # Wrap string module names into keyed imports so the module system dedupes them.
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

  resolveNix = mkResolver "nixos" "nixos";
  resolveHm = mkResolver "homeManager" "hm";
  resolveDarwin = mkResolver "darwin" "darwin";
in {
  config.flake.lib = {
    # NixOS modules: imports = config.flake.lib.resolveNix [ "presets/server" "secrets" ../../hardware.nix ];
    inherit resolveNix;

    # Home Manager modules: imports = config.flake.lib.resolveHm [ "users" "dotfiles" ];
    inherit resolveHm;

    # Darwin modules: imports = config.flake.lib.resolveDarwin [ "security" "homebrew" ];
    inherit resolveDarwin;

    # Distribute a module list to NixOS, Darwin, and Home Manager by existence.
    resolve = modules: let
      mods = config.flake.modules or {};
      namespaces = ["nixos" "darwin" "homeManager"];

      # Does a string name exist in this namespace?
      hasModule = ns: m: builtins.isString m && builtins.hasAttr m (mods.${ns} or {});

      # A feature may ship a companion module named `preservation/<feature>`
      # holding its reboot-persistent state, in the namespace it configures.
      # Companions are imported automatically so features stay preservation-agnostic.
      # Every name is scanned against the target namespace because the feature
      # itself may live in another namespace (e.g. a Home-Manager-only app).
      preservationPrefix = "preservation/";
      companionsFor = ns: let
        names = mods.${ns} or {};
        candidates =
          builtins.map (n: preservationPrefix + n)
          (builtins.filter builtins.isString modules);
      in
        lib.unique (builtins.filter (c: builtins.hasAttr c names) candidates);

      nixosCompanions = companionsFor "nixos";
      darwinCompanions = companionsFor "darwin";
      hmCompanions = companionsFor "homeManager";

      # Names per namespace plus companions; the "preservation" base module is
      # pulled in automatically whenever a NixOS-side companion needs it.
      stringsFor = ns: companions:
        lib.unique (builtins.filter (hasModule ns) modules ++ companions);

      nixosStr = stringsFor "nixos" (lib.optional (nixosCompanions != []) "preservation" ++ nixosCompanions);
      darwinStr = stringsFor "darwin" darwinCompanions;
      hmStr = stringsFor "homeManager" hmCompanions;

      # Paths and other non-strings pass through as normal imports
      nonStrings = builtins.filter (m: !builtins.isString m) modules;

      # Unknown names fail fast with a readable error instead of Nix's
      # bare "attribute missing" one.
      showNames = ns: let
        names = builtins.attrNames (mods.${ns} or {});
      in
        if names == []
        then "(none)"
        else lib.concatStringsSep ", " names;
      missingStrings =
        builtins.map (m: {
          key = "dendritic-missing-${m}";
          imports = [
            (throw ''
              flake.lib.resolve: module "${m}" does not exist in any namespace.

              String entries must name modules declared under flake.modules.<namespace>.

              Available modules:
                nixos:       ${showNames "nixos"}
                darwin:      ${showNames "darwin"}
                homeManager: ${showNames "homeManager"}
            '')
          ];
        })
        (builtins.filter (m: builtins.isString m && !builtins.any (ns: hasModule ns m) namespaces) modules);

      resolvedNixos = resolveNix nixosStr;
      resolvedDarwin = resolveDarwin darwinStr;
      resolvedHm = resolveHm hmStr;

      defaultUser = config.flake.meta.user.username or "default";
    in
      [
        # NixOS or darwin depending on target (NixOS injects `modulesPath`).
        ({...} @ hostArgs: {
          imports =
            nonStrings
            ++ missingStrings
            ++ lib.optionals (hostArgs ? modulesPath) resolvedNixos
            ++ lib.optionals (!(hostArgs ? modulesPath)) resolvedDarwin;
        })
      ]
      # HM modules attach to the default user; a static attrset avoids HM dedup
      # issues that arise when wrapped dynamically.
      ++ lib.optionals (resolvedHm != []) [
        {
          home-manager.users.${defaultUser}.imports = resolvedHm;
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
