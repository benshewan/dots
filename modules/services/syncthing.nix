{config, ...}: let
  username = config.flake.meta.user.username;
in {
  # group = "ben" fails with status=216/GROUP — the user's primary group
  # is "users" (users.nix), no per-user group exists.
  flake.modules.nixos."services/syncthing" = {
    services.syncthing = {
      enable = true;
      user = username;
      group = "users";
      dataDir = "/home/${username}";
    };
  };

  # Preservation companion for "services/syncthing" (auto-resolved by the
  # prefix). The NixOS module points BOTH --config and --data at
  # /home/<u>/.config/syncthing, so everything lives in one dir: config.xml
  # (devices, folders), key.pem/cert.pem (device identity — losing it
  # changes the syncthing ID), https certs and the index-v2 database.
  flake.modules.nixos."preservation/services/syncthing" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username} = {
      directories = [
        ".config/syncthing"
      ];
    };
  };
}
