{
  pkgs,
  lib,
  ...
}: {
  programs = {
    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
    fish.enable = true;
    bash.enable = true; # see note on other shells below
  };

  home.packages = with pkgs; [
    eza
  ];

  # programs.eza.enableAliases = true;
  programs.fish.shellInit = ''
    set fish_greeting
  '';

  programs.fish.interactiveShellInit = ''
    ${lib.getExe pkgs.nix-your-shell} fish | source
  '';
}
