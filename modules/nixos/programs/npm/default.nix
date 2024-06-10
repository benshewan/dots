{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.night-sky.programs.npm;
in {
  options.night-sky.programs.npm = {
    enable = lib.mkEnableOption "npm";
  };

  config = lib.mkIf cfg.enable {
    environment.sessionVariables.NODE_REPL_HISTORY = ''$XDG_CACHE_HOME/node_repl_history'';

    environment.systemPackages = with pkgs; [
      nodejs
    ];

    programs.npm = {
      enable = true;
      npmrc = ''
        prefix = $XDG_CACHE_HOME/npm
        color = true
        fund = false
      '';
    };
  };
}
