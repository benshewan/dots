_: {
  flake.modules.homeManager."programs/helix" = {pkgs, ...}: {
    programs.helix = {
      enable = true;
    };
  };
}
