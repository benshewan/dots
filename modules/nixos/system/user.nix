{
  pkgs,
  outputs,
  ...
}: {
  # Set your time zone.
  time.timeZone = "America/Halifax";
  programs.gnupg.agent.pinentryPackage = pkgs.pinentry-qt;

  users = {
    groups = {
      "${outputs.username}" = {};
    };
    users.${outputs.username} = {
      isNormalUser = true;
      description = outputs.userDescription;
      initialPassword = "admin";
      extraGroups = ["wheel" "docker" "video" "libvirtd" "plugdev" "${outputs.username}"];
    };
  };
}
