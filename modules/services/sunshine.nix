_: {
  flake.modules.nixos."services/sunshine" = {pkgs, ...}: {
    services.sunshine = {
      enable = true;
      autoStart = true;
      openFirewall = true;
    };
  };
}
