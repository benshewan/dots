_: {
  flake.modules.homeManager."programs/direnv" = {
    pkgs,
    config,
    ...
  }: {
    programs.direnv = {
      enable = true;
      silent = true;
      nix-direnv.enable = true;
      enableFishIntegration = true;
    };
  };
}
