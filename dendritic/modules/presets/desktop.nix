{config, ...}: {
  # Desktop preset - full desktop environment with all features
  # Replaces the mkHost preset="desktop" pattern with explicit dendritic imports
  #
  # Based on config.flake.meta.presets.desktop:
  #   modules: users, fonts, security, desktop, applications, development, shell
  #   nixos: system, vpn
  #   homeManager: dotfiles

  flake.modules.nixos."presets/desktop" = {
    imports = config.flake.lib.resolve [
      # Common modules
      "users"
      # "services/flatpak" # need a desktop environment
      "services/printing"
      "services/timezone"
      "programs/direnv"
      "programs/comma"
      # NixOS-specific
      "system"
      "system/ananicy"
    ];
  };

  # For Home Manager contexts (e.g., macOS with home-manager only)
  flake.modules.homeManager."presets/desktop" = {
    imports = config.flake.lib.resolveHm [
      # All desktop features for home-manager-only systems
      "users"
      "monitors"
      "programs/git"
      "programs/firefox"
      "programs/vscode"
    ];
  };
}
