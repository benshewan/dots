{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.plasma-manager.homeManagerModules.plasma-manager
  ];

  programs.kitty = {
    enable = true;
    package = pkgs.kitty;
    shellIntegration.enableFishIntegration = true;
    settings = {
      scrollback_lines = 10000;
      confirm_os_window_close = 0;
    };
  };
  programs.plasma.enable = true;
  programs.plasma.configFile.kdeglobals.General.TerminalApplication = toString pkgs.kitty;

  # home.file.".local/share/terminfo" = {
  #   source = "${pkgs.kitty}/lib/kitty/terminfo";
  #   recursive = true;
  # };
  # home.shellAliases.ssh = toString ./ssh.sh;
  # home.sessionVariables.TERM = "xterm";
}
