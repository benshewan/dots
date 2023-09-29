{pkgs, ...}: {
  programs.fish = {
    enable = true;
  };

  programs = {
    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
    bash.enable = true; # see note on other shells below
  };

  home.packages = with pkgs; [
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
