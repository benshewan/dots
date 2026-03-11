_: {
  flake.modules.nixos."programs/npm" = {pkgs, ...}: {
    environment.sessionVariables.NODE_REPL_HISTORY = ''$XDG_CACHE_HOME/node_repl_history'';

    environment.systemPackages = with pkgs; [
      nodejs
    ];

    programs.npm = {
      enable = true;
      npmrc = ''
        prefix=''${XDG_DATA_HOME}/npm
        cache=''${XDG_CACHE_HOME}/npm
        init-module=''${XDG_CONFIG_HOME}/npm/config/npm-init.js
        logs-dir=''${XDG_STATE_HOME}/npm/logs
        color = true
        fund = false
      '';
    };
  };
}
