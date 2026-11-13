{
  flake.modules.nixos.desktop = {pkgs, ...}: {
    hardware.bluetooth = {
      enable = true;
      package = pkgs.bluez5-experimental;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = "true";
        };
      };
    };
  };

  # Preservation companion for "desktop" (auto-resolved by the prefix).
  flake.modules.nixos."preservation/desktop" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.directories = [
      # Paired devices and adapter state.
      "/var/lib/bluetooth"
    ];
  };
}
