_: {
  flake.modules.homeManager."programs/kitty" = {pkgs, ...}: {
    programs = {
      kitty = {
        enable = true;
        package = pkgs.kitty;
        enableGitIntegration = true;
        settings = {
          scrollback_lines = 10000;
          confirm_os_window_close = 0;
        };
      };
    };
  };
}
