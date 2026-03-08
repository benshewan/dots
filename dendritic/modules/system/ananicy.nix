_: {
  # Should only be used for desktops
  flake.modules.nixos."system/ananicy" = {pkgs, ...}: {
    services.ananicy = {
      enable = true;
      # Use ananicy-cpp for better performance (C++ rewrite of original ananicy)
      package = pkgs.ananicy-cpp;
      # Use CachyOS rules - comprehensive ruleset for servers and desktops
      # Includes rules for common services, databases, media servers, etc.
      rulesProvider = pkgs.ananicy-rules-cachyos;
    };
  };
}
