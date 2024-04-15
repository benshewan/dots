{
  outputs,
  lib,
  pkgs,
  ...
}: {
  imports = [./global ../shared/desktop-enviroments/gnome.nix];

  home.shellAliases = {
    home-switch = "home-manager switch --flake ${outputs.src}#ben@lepus";
  };

  gtk.theme = lib.mkForce {
    name = "Catppuccin-Mocha-Standard-Blue-Dark";
    package =
      pkgs.catppuccin-gtk.override
      {
        accents = ["blue"];
        size = "standard"; # compact
        tweaks = [];
        variant = "mocha";
      };
  };
}
