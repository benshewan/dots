{
  pkgs,
  outputs,
  ...
}: {
  hardware.openrazer.enable = true;
  hardware.openrazer.users = [config.night-sky.user.name];
  environment.systemPackages = with pkgs; [
    (python3.withPackages (ps: with ps; [openrazer]))
    razergenie
  ];
}
