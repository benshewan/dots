{config, ...}: {
  services.syncthing = {
    enable = true;
    user = config.night-sky.user.name;
    group = config.night-sky.user.name;
    dataDir = "/home/${config.night-sky.user.name}";
  };
}
