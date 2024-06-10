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
