_: {
  flake.modules.homeManager."programs/python" = {
    pkgs,
    config,
    lib,
    ...
  }: {
    # Single owner of the user's python: everything goes through one
    # withPackages env. A bare python3 in home.packages would collide with
    # this env in home-manager-path (buildEnv subpath conflict on
    # bin/python3-config), so other modules must extend via extraPackages.
    options.programs.python.extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Python packages added to the user's python environment.";
    };

    config = {
      home.sessionVariables.PYTHON_HISTORY = ''${config.xdg.cacheHome}/python_history'';
      # handled by config.home.preferXdgDirectories
      # home.sessionVariables.NPM_CONFIG_USERCONFIG = ''$XDG_CONFIG_HOME/npm/npmrc'';

      home.packages = [
        (pkgs.python3.withPackages (ps: config.programs.python.extraPackages))
      ];
    };
  };
}
