_: {
  flake.modules.nixos."programs/direnv" = {
    pkgs,
    config,
    ...
  }: {
    programs.direnv = {
      silent = false;
      loadInNixShell = true;
      nix-direnv.enable = true;
    };
  };
}
