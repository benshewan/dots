_: {
  flake.modules.nixos."programs/steam" = {pkgs, ...}: {
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
    };

    programs.gamescope = {
      enable = true;
    };
  };
}
