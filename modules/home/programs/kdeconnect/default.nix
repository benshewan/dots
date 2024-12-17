{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.night-sky.programs.kdeconnect;
  inherit (pkgs.stdenv) isLinux;
in {
  options.night-sky.programs.kdeconnect = {
    enable = lib.mkEnableOption "kdeconnect";
  };

  config = lib.mkIf cfg.enable {
    xdg.desktopEntries = {
      "org.kde.kdeconnect.sms" = {
        exec = "";
        name = "KDE Connect SMS";
        settings.NoDisplay = "true";
      };
      "org.kde.kdeconnect.nonplasma" = {
        exec = "";
        name = "KDE Connect Indicator";
        settings.NoDisplay = "true";
      };
      "org.kde.kdeconnect.app" = {
        exec = "";
        name = "KDE Connect";
        settings.NoDisplay = "true";
      };
      "org.kde.kdeconnect_open" = {
        exec = "";
        name = "Open on connected device via KDE Connect";
        settings.NoDisplay = "true";
      };
    };

    services.kdeconnect = {
      enable = true;
      indicator = false;
    };
  };
}
