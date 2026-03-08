{config, ...}: {
  flake.modules.nixos."services/syncthing" = {pkgs, ...}: {
    services.syncthing = {
      enable = true;
      user = config.flake.meta.user.username;
      group = config.flake.meta.user.username;
      dataDir = "/home/${config.flake.meta.user.username}";
    };
  };
}
