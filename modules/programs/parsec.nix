{config, ...}: let
  username = config.flake.meta.user.username;
in {
  flake.modules.homeManager."programs/parsec" = {pkgs, ...}: {
    home.packages = with pkgs; [
      parsec-bin
    ];
  };

  # Preservation companion for "programs/parsec" (auto-resolved by the
  # prefix). Audited live: parsec writes everything to the home ROOT:
  # - .parsec/ — settings (config.json, config.txt, hotkey.json),
  #   appdata.json, the extracted SDK .so and logs. The zero-byte `lock`
  #   file is a runtime single-instance lock, rides along harmlessly.
  # - .parsec-persistent/ — devid.bin is the per-computer device identity
  #   (losing it = re-pairing the machine) plus status.json.
  flake.modules.nixos."preservation/programs/parsec" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username} = {
      directories = [
        ".parsec"
        ".parsec-persistent"
      ];
    };
  };
}
