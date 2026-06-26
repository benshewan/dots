_: {
  flake.modules.homeManager."programs/python" = {
    pkgs,
    config,
    ...
  }: {
    home.sessionVariables.PYTHON_HISTORY = ''${config.xdg.cacheHome}/python_history'';
    # handled by config.home.preferXdgDirectories
    # home.sessionVariables.NPM_CONFIG_USERCONFIG = ''$XDG_CONFIG_HOME/npm/npmrc'';

    home.packages = with pkgs; [
      python3
    ];
  };
}
