{
  lib,
  osConfig ? {},
  ...
}: {
  home.stateVersion = lib.mkDefault (osConfig.system.stateVersion or "23.11");
  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
