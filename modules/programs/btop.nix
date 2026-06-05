_: {
  flake.modules.homeManager."programs/btop" = {pkgs, ...}: {
    programs.btop = {
      enable = true;
    };
  };
}
