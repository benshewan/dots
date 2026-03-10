{config, ...}: {
  # Desktop preset - full desktop environment with all features
  # Replaces the mkHost preset="desktop" pattern with explicit dendritic imports
  #
  # Based on config.flake.meta.presets.desktop:
  #   modules: users, fonts, security, desktop, applications, development, shell
  #   nixos: system, vpn
  #   homeManager: dotfiles

  flake.modules.nixos."presets/hyprland" = {
    imports = config.flake.lib.resolve [
      "display-managers/tuigreet"
      "window-managers/hyprland"
    ];
  };

  # For Home Manager contexts (e.g., macOS with home-manager only)
  flake.modules.homeManager."presets/hyprland" = {pkgs, ...}: {
    imports = config.flake.lib.resolveHm [
      "window-managers/hyprland"
      "programs/satty"
      "programs/rofi"
      "programs/kitty"
    ];

    home.packages = with pkgs; [
      stable.pavucontrol # Audio Control
      loupe
      foliate
    ];
  };
}
