_: {
  flake.modules.homeManager."programs/fish" = {
    pkgs,
    lib,
    ...
  }: {
    programs.fish = {
      enable = true;
      # Blank shell greeting
      shellInit = ''
        set fish_greeting
      '';
      interactiveShellInit = ''
        ${lib.getExe pkgs.nix-your-shell} fish | source
      '';
    };
  };
}
