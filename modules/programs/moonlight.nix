{config, ...}: let
  username = config.flake.meta.user.username;
in {
  flake.modules.homeManager."programs/moonlight" = {pkgs, ...}: {
    home.packages = with pkgs; [
      moonlight-qt
    ];
  };

  # Preservation companion for "programs/moonlight" (auto-resolved by the
  # prefix). Whole dir: Moonlight.conf (settings, written at startup) and,
  # once a host is paired, the client TLS keypair (client.pem/client.key)
  # and uniqueid — losing those means re-pairing with every Sunshine host.
  flake.modules.nixos."preservation/programs/moonlight" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username} = {
      directories = [
        ".config/Moonlight Game Streaming Project"
      ];
    };
  };
}
