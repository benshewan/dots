{outputs, ...}: {
  imports = [./global ../shared/desktop-enviroments/gnome.nix];

  home.shellAliases = {
    home-switch = "home-manager switch --flake ${outputs.src}#ben@corvus";
  };
}
