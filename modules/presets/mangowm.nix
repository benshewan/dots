{config, ...}: {
  # Desktop preset - full desktop environment with all features
  # Replaces the mkHost preset="desktop" pattern with explicit dendritic imports
  #
  # Based on config.flake.meta.presets.desktop:
  #   modules: users, fonts, security, desktop, applications, development, shell
  #   nixos: system, vpn
  #   homeManager: dotfiles

  flake.modules.nixos."presets/mangowm" = {
    imports = config.flake.lib.resolve [
      # "display-managers/noctalia-greeter"
      "display-managers/sddm"
      "window-managers/mangowm"

      # Software
      "programs/satty"
      "programs/rofi"
      "programs/kitty"
    ];
  };

  # For Home Manager contexts (e.g., macOS with home-manager only)
  flake.modules.homeManager."presets/mangowm" = {pkgs, ...}: {
    home.packages = with pkgs; [
      stable.pavucontrol # Audio Control

      # Should move these somewhere else, not really preset material
      loupe
      foliate
    ];
  };
}
