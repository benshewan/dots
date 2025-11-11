{
  options,
  config,
  lib,
  ...
}:
with lib;
with lib.night-sky; let
  cfg = config.night-sky.home;
in {
  options.night-sky.home = with types; {
    file =
      mkOpt attrs {}
      (mdDoc "A set of files to be managed by home-manager's `home.file`.");
    configFile =
      mkOpt attrs {}
      (mdDoc "A set of files to be managed by home-manager's `xdg.configFile`.");
    extraOptions = mkOpt attrs {} "Options to pass directly to home-manager.";
  };

  config = {
    environment.sessionVariables = {
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_STATE_HOME = "$HOME/.local/state";

      # Home Directory cleanup
      _JAVA_OPTIONS = ''-Djava.util.prefs.userRoot=/home/${config.night-sky.user.name}/.config/java -Dawt.useSystemAAFontSettings=lcd''; # Java
      XCOMPOSEFILE = ''$XDG_CONFIG_HOME/X11/xcompose''; # X11
      XCOMPOSECACHE = ''$XDG_CACHE_HOME/X11/xcompose''; # x11
      CARGO_HOME = ''$XDG_CACHE_HOME/cargo''; # Rust
    };

    night-sky.home.extraOptions = {
      home.stateVersion = config.system.stateVersion;
      home.file = mkAliasDefinitions options.night-sky.home.file;
      xdg.enable = true;
      xdg.configFile = mkAliasDefinitions options.night-sky.home.configFile;
    };

    snowfallorg.users.${config.night-sky.user.name}.home.config = cfg.extraOptions;

    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;
      backupFileExtension = "backup";
    };
  };
}
