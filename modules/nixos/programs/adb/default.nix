{config, ...}: {
  programs.adb.enable = true;
  users.users.${config.night-sky.user.name}.extraGroups = ["adbusers"];
}
