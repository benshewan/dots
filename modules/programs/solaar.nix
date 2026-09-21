_: {
  # Solaar is the driver/GUI for Logitech devices.
  # (hardware.logitech.wireless.enableGraphical was renamed to programs.solaar.enable)
  flake.modules.nixos."programs/solaar" = {
    programs.solaar.enable = true;
  };
}
