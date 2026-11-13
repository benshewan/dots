{config, ...}: let
  username = config.flake.meta.user.username;
in {
  flake.modules.homeManager."programs/npm" = {
    pkgs,
    config,
    ...
  }: {
    home.sessionVariables.NODE_REPL_HISTORY = ''${config.xdg.cacheHome}/node_repl_history'';
    # handled by config.home.preferXdgDirectories
    # home.sessionVariables.NPM_CONFIG_USERCONFIG = ''$XDG_CONFIG_HOME/npm/npmrc'';

    home.packages = with pkgs; [
      nodejs
    ];

    programs.npm = {
      enable = true;
      settings = {
        prefix = ''''${XDG_DATA_HOME}/npm'';
        cache = ''''${XDG_CACHE_HOME}/npm'';
        init-module = ''''${XDG_CONFIG_HOME}/npm/config/npm-init.js'';
        logs-dir = ''''${XDG_STATE_HOME}/npm/logs'';
        color = true;
        fund = false;
      };
    };
  };

  # Preservation companion for "programs/npm" (auto-resolved by the
  # prefix). The npmrc (HM-generated, read via NPM_CONFIG_USERCONFIG from
  # the HM session env) diverts everything XDG: cache → .cache/npm,
  # logs → .local/state/npm/logs (skip both). The durable part is the
  # GLOBAL prefix: ~/.local/share/npm (npm install -g packages and bins).
  # NOTE: shells without the HM profile env (runuser, cron) don't set
  # NPM_CONFIG_USERCONFIG — npm then falls back to ~/.npmrc + ~/.npm.
  flake.modules.nixos."preservation/programs/npm" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username} = {
      directories = [
        ".local/share/npm"
      ];
    };
  };
}
