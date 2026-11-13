{
  lib,
  ...
} @ flake: let
  username = flake.config.flake.meta.user.username;
in {
  # Nix OS
  flake.modules.nixos.users = {
    pkgs,
    config,
    lib,
    ...
  }: {
    # Decrypt before user creation so hashedPasswordFile is available.
    sops.secrets."user-password".neededForUsers = true;

    # Password is fully declarative: the shadow hash is forced from the sops
    # secret on every activation, and passwd(1) changes are reverted. Update
    # the password by editing the `user-password` secret, not with passwd(1).
    users.mutableUsers = false;

    users.users.${username} = {
      isNormalUser = true;
      description = flake.config.flake.meta.user.fullName;
      extraGroups = [
        "wheel" # For sudo access
        "dialout" # For serial deivce access
        "video" # For backlight control
      ];
      shell = lib.mkOverride 500 pkgs.fish; # can't use mkDefault because others set a default
      ignoreShellProgramCheck = true;
      hashedPasswordFile = config.sops.secrets."user-password".path;
    };
  };

  # Home Manager
  flake.modules.homeManager.users = {
    pkgs,
    lib,
    ...
  }: let
    avatarFile =
      if flake.config.flake.meta.user.avatar.source != null
      then flake.config.flake.meta.user.avatar.source
      else
        pkgs.fetchurl {
          inherit (flake.config.flake.meta.user.avatar) url sha256;
        };
  in {
    programs.home-manager.enable = true;
    systemd.user.startServices = lib.mkDefault "sd-switch";

    home = {
      inherit (flake.config.flake.meta.user) username;
      homeDirectory = lib.mkDefault "/home/${flake.config.flake.meta.user.username}";
      stateVersion = "25.05";

      # Link avatar to .face for display managers
      file.".face".source = avatarFile;
    };
  };
}
