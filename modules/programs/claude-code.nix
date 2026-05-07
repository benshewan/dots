_: {
  flake.modules.homeManager."programs/claude-code" = {pkgs, ...}: {
    programs.claude-code = {
      enable = true;
    };
  };
}
