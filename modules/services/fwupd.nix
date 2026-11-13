{
  flake.modules.nixos."services/fwupd" = {pkgs, ...}: {
    services.fwupd = {
      enable = true;
      extraRemotes = ["lvfs-testing"]; # Enable beta bios
    };
  };

  # Preservation companion for "services/fwupd" (auto-resolved by the prefix).
  flake.modules.nixos."preservation/services/fwupd" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.directories = [
      # LVFS metadata, remotes and pending update state.
      "/var/lib/fwupd"
    ];
  };
}
