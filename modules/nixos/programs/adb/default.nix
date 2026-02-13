{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [android-tools];
  users.users.${config.night-sky.user.name}.extraGroups = ["adbusers"];
}
