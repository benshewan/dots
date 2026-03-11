_: {
  flake.modules.homeManager."programs/bash" = {
    pkgs,
    config,
    ...
  }: {
    home.sessionVariables.HISTFILE = ''${config.xdg.cacheHome}/bash_history'';

    programs.bash = {
      enable = true;
    };
  };
}
