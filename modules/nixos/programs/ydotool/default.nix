{config, ...}: {
  programs.ydotool.enable = true;
  users.users.${config.night-sky.user.name}.extraGroups = ["ydotool"];
}
