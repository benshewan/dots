{config, ...}: {
  flake.modules.nixos."programs/adb" = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [android-tools];
    users.users.${config.flake.meta.user.username}.extraGroups = ["adbusers"];
  };
}
