_: {
  flake.modules.nixos."services/avahi" = {pkgs, ...}: {
    # Allow for network auto-discovery of a variety of things
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
