{
  outputs,
  pkgs,
  ...
}: {
  imports = [./global ../shared/desktop-enviroments/hyprland];

  home.shellAliases = {
    home-switch = "home-manager switch --flake ${outputs.flake-path}#ben@sirius";
  };

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
    ];
  };
}
