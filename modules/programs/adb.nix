{config, ...}: {
  flake.modules.nixos."programs/adb" = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [android-tools];
    users.users.${config.flake.meta.user.username}.extraGroups = ["adbusers"];

    services.udev.packages = [ pkgs.libmtp.out ]; # Needed for regular file transfer over MTP
  };
}
