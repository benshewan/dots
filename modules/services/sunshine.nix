{config, ...}: let
  username = config.flake.meta.user.username;
in {
  flake.modules.nixos."services/sunshine" = {pkgs, ...}: {
    services.sunshine = {
      enable = true;
      autoStart = true;
      openFirewall = true;
    };
  };

  # Preservation companion for "services/sunshine" (auto-resolved by the
  # prefix). Everything sunshine owns sits in one dir: sunshine.conf,
  # apps.json (custom app entries) and credentials/ (Moonlight pairings).
  # Runs as a systemd USER service (wanted by graphical-session.target).
  flake.modules.nixos."preservation/services/sunshine" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username} = {
      directories = [
        ".config/sunshine"
      ];
    };
  };
}
