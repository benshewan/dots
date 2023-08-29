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
    };
  };
  programs.fish.functions = { ssh = "kitty +kitten ssh"; };
}
