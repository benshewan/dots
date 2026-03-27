_: {
  # A Logitech pairing app
  flake.modules.nixos."programs/solaar" = {pkgs, ...}: {
    hardware.logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };
  };
}
