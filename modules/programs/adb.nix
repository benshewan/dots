{config, ...}: let
  # Flake-level user metadata; config.flake does not exist inside
  # NixOS modules, which shadow `config` with the host config.
  username = config.flake.meta.user.username;
in {
  flake.modules.nixos."programs/adb" = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [android-tools];
    users.users.${config.flake.meta.user.username}.extraGroups = ["adbusers"];

    services.udev.packages = [pkgs.libmtp.out]; # Needed for regular file transfer over MTP
  };

  # Preservation companion for "programs/adb" (auto-resolved by the prefix).
  # `@ nixos` binds the host's NixOS config (modules.preservation lives
  # there); the file-level `config` is the flake config, since config.flake
  # does not exist inside NixOS modules.
  flake.modules.nixos."preservation/programs/adb" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username}.directories = [
      # Authorized-host keys and paired-device state. The ANDROID_USER_HOME
      # redirect to XDG data was removed: adb (and friends) still write
      # state to ~/.android on startup, so the real location is preserved
      # instead of a half-effective redirect.
      {directory = ".android"; mode = "0700";}
    ];
  };
}
