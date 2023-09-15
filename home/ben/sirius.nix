{ outputs, ... }:
{
  imports = [ ./global ../shared/desktop-enviroments/hyprland ];

  home.shellAliases = {
    home-switch = "home-manager switch --flake ${outputs.flake-path}#ben@sirius";
  };
}
