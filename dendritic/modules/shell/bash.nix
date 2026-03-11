_: {
  flake.modules.homeManager."programs/bash" = {pkgs, ...}: {
    programs.bash = {
      enable = true;
    };
  };
}
