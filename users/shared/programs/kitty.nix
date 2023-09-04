{ pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    font.package = (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; });
    font.name = "JetBrainsMono";
    theme = "Catppuccin-Mocha";
    shellIntegration.enableFishIntegration = true;
    settings = {
      scrollback_lines = 10000;
      confirm_os_window_close = 0;
    };
  };
  programs.fish.functions = { ssh = "kitty +kitten ssh"; };
}
