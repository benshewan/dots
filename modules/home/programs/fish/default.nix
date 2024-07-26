{
  pkgs,
  lib,
  ...
}: let
  fish-ssh-agent = {
    name = "fish_ssh_agent";
    src = pkgs.fetchFromGitHub {
      owner = "ivakyb";
      repo = "fish_ssh_agent";
      rev = "c7aa080d5210f5f525d078df6fdeedfba8db7f9b";
      sha256 = "";
    };
  };
in {
  programs = {
    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
    nix-index.enableFishIntegration = true;
    fish.enable = true;
    bash.enable = true; # see note on other shells below
  };

  programs.fish.plugins = [
    {
      name = "fish-ssh-agent";
      src = pkgs.fetchFromGitHub {
        owner = "danhper";
        repo = "fish-ssh-agent";
        rev = "fd70a2afdd03caf9bf609746bf6b993b9e83be57";
        sha256 = "sha256-e94Sd1GSUAxwLVVo5yR6msq0jZLOn2m+JZJ6mvwQdLs=";
      };
    }
  ];

  programs.fish.functions = {
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
