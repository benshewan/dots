{
  outputs,
  pkgs,
  lib,
  ...
}: {
  imports = [./global ../shared/desktop-enviroments/kde.nix];

  home.shellAliases = {
    home-switch = "home-manager switch --flake ${outputs.flake-path}#ben@sirius";
  };

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
    ];
  };

  qt = {
    platformTheme = lib.mkForce "kde";
    # style.name = "gtk2";
  };
}
