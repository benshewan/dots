{config, ...}: {
  flake.modules.nixos."programs/adb" = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [android-tools];
    users.users.${config.flake.meta.user.username}.extraGroups = ["adbusers"];

    services.udev.packages = [ pkgs.libmtp.out ]; # Needed for regular file transfer over MTP
  };

  # Home Manager: move ~/.android to XDG data location
  flake.modules.homeManager."programs/adb" = {config, ...}: {
    home.sessionVariables.ANDROID_USER_HOME = "${config.xdg.dataHome}/android";
  };
}
