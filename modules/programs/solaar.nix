{config, ...}: let
  username = config.flake.meta.user.username;
in {
  # Solaar is the driver/GUI for Logitech devices.
  # (hardware.logitech.wireless.enableGraphical was renamed to programs.solaar.enable)
  flake.modules.nixos."programs/solaar" = {
    programs.solaar.enable = true;
  };

  # Preservation companion for "programs/solaar" (auto-resolved by the
  # prefix). Solaar writes nothing at first launch with no Logitech device
  # attached — settings (config.yaml) and rules (rules.yaml) only appear in
  # ~/.config/solaar once a device's settings are changed. Directory mount
  # so the file writes inside can't hit the EBUSY file-mount trap.
  flake.modules.nixos."preservation/programs/solaar" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username} = {
      directories = [
        ".config/solaar"
      ];
    };
  };
}
