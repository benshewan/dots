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

  # Preservation companion for "desktop" (Bluetooth is enabled above).
  # `config.flake.lib.resolve` imports it (together with the base preservation
  # module) automatically because of the "preservation/" prefix. Upstream
  # ignores `preserveAt` until `preservation.enable` is true.
  flake.modules.nixos."preservation/desktop" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.directories = [
      # Paired devices and adapter state.
      "/var/lib/bluetooth"
    ];
  };
}
