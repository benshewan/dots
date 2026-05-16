{...}: {
  flake.modules.nixos."security/yubikey" = {
    pkgs,
    lib,
    config,
    ...
  }: {
    programs.yubikey-manager.enable = true;
    services.pcscd.enable = true;
    environment.systemPackages = with pkgs; [yubikey-manager];

    # Preserve SSH agent socket across sudo so yubikey sk keys work during nixos-rebuild
    security.sudo.extraConfig = ''
      Defaults env_keep += "SSH_AUTH_SOCK"
    '';
  };
}
