{pkgs, ...}: {
  # Add support for ~/.local/bin
  environment.localBinInPath = true;

  # Shell
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;
  environment.shellAliases = {
    reboot = "systemctl reboot";
    poweroff = "systemctl poweroff";
  };
}
