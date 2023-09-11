{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
  };

  home.packages = with pkgs;[
    eza
  ];

  programs.eza.enableAliases = true;
  programs.fish.shellInit = ''
    set fish_greeting
    direnv hook fish | source
  '';
  programs.fish.interactiveShellInit = ''
    
  '';
}
