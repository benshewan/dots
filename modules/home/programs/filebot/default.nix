{
  config,
  pkgs,
  lib,
  namespace,
  ...
}: let
  cfg = config.night-sky.programs.filebot;
  inherit (pkgs.stdenv) isLinux;
in {
  options.night-sky.programs.filebot = {
    enable = lib.mkEnableOption "filebot";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [filebot];

    sops.secrets."filebot-license" = {
      path = "${config.${namespace}.user.home}/.local/share/filebot/data/.license";
    };
  };
}
