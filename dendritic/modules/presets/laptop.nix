{config, ...}: {
  # Desktop preset - full desktop environment with all features
  # Replaces the mkHost preset="desktop" pattern with explicit dendritic imports
  #
  # Based on config.flake.meta.presets.desktop:
  #   modules: users, fonts, security, desktop, applications, development, shell
  #   nixos: system, vpn
  #   homeManager: dotfiles

  flake.modules.nixos."presets/laptop" = {
    imports = config.flake.lib.resolve [
      "presets/desktop"
      "services/upower"
    ];
  };

  # For Home Manager contexts (e.g., macOS with home-manager only)
  flake.modules.homeManager."presets/laptop" = {
    imports = config.flake.lib.resolveHm [
      # All desktop features for home-manager-only systems
      "presets/desktop"
    ];
  };
}
