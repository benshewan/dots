{outputs, ...}: {
  services.syncthing = {
    enable = true;
    user = outputs.username;
    group = outputs.username;
    dataDir = "/home/${outputs.username}";
  };
}
