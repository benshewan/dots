{pkgs, ...}: {
  programs.kitty = {
    enable = true;
    shellIntegration.enableFishIntegration = true;
    settings = {
      scrollback_lines = 10000;
      confirm_os_window_close = 0;
    };
  };
  # home.shellAliases.ssh = toString ./ssh.sh;
  # home.sessionVariables.TERM = "xterm";
}
