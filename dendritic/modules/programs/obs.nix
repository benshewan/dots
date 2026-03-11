_: {
  flake.modules.homeManager."programs/obs" = {
    pkgs,
    lib,
    ...
  }: {
    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
      ];
    };
  };
}
