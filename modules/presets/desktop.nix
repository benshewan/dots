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
      "desktop"
      "monitors"
      # Services
      "services/flatpak"
      "services/printing"
      "services/timezone"
      "services/ssh"
      # Software
      "programs/comma"
      "programs/vscode"
      "programs/git"
      "programs/firefox"
      "programs/vscode"
      "programs/fish"
      "programs/bash"
      "programs/direnv"
      # NixOS-specific
      "system"
      "system/ananicy"
    ];
  };
}
