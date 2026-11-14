{config, ...}: {
  # Server preset - combines common server modules
  # Replaces the mkHost preset="server" pattern with explicit dendritic imports
  #
  # Based on config.flake.meta.presets.server:
  #   modules: users, security, development, shell
  #   nixos: system, vpn
  #   homeManager: dotfiles

  flake.modules.nixos."presets/server" = {
    imports = config.flake.lib.resolve [
      # Common modules
      "users"
      "services/ssh"

      # NixOS-specific
      "system"
    ];
  };
}
