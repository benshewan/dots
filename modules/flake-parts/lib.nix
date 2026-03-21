{
  config,
  lib,
  ...
}: {
  config.flake.lib = {
    # Dendritic pattern helpers for module path resolution
    # These helpers allow using string paths in imports while maintaining dendritic pattern compliance

    # Resolve NixOS module paths
    # Usage: imports = config.flake.lib.resolve [ "presets/server" "secrets" ../../hardware.nix ];
    resolve = builtins.map (m:
      if builtins.isString m
      then config.flake.modules.nixos.${m}
      else m);

    # Resolve Home Manager module paths
    # Usage: home-manager.users.username.imports = config.flake.lib.resolveHm [ "users" "dotfiles" ];
    resolveHm = builtins.map (
      m:
        if builtins.isString m
        then config.flake.modules.homeManager.${m}
        else m
    );

    # Resolve Darwin module paths
    # Usage: imports = config.flake.lib.resolveDarwin [ "security" "homebrew" ];
    resolveDarwin = builtins.map (
      m:
        if builtins.isString m
        then config.flake.modules.darwin.${m}
        else m
    );

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
