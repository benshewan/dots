{ ... }:
{
    imports = [
      ../../shared
      ../../shared/desktop-enviroments/gnome.nix
      ../../shared/desktop-enviroments/kde.nix
      ../../shared/desktop-enviroments/hyprland
      ./packages.nix
    ];
}