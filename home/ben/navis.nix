{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./global
    ../shared/desktop-enviroments/kde.nix
  ];

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

  #   dconf.settings."org.gnome.mutter" = {
  #     experimental-features = ["scale-monitor-framebuffer"];
  #   };
}
