{outputs, ...}: {
  programs.adb.enable = true;
  users.users.${outputs.username}.extraGroups = ["adbusers"];
}
