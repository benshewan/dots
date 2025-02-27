{
  pkgs,
  config,
  lib,
  namespace,
  ...
}: let
  cfg = config.night-sky.programs.webstorm;
in {
  options.night-sky.programs.webstorm = {
    enable = lib.mkEnableOption "webstorm";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      (jetbrains.webstorm.override {
        vmopts = ''
          -Xmx4G
          -Xms2G
          --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED
          --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED
          -javaagent:${config.${namespace}.user.home}/.config/JetBrains/crack/ja-netfilter.jar=jetbrains
          # -Dawt.toolkit.name=WLToolkit
        '';
      })
    ];
  };
}
