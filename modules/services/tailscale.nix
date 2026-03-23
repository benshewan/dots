_: {
  flake.modules.nixos."services/tailscale" = {pkgs, ...}: {
    services.tailscale = {
      enable = true;
    };
  };
}
