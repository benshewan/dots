{
  pkgs,
  outputs,
  ...
}: {
  hardware.openrazer.enable = true;
  hardware.openrazer.users = [outputs.username];
  environment.systemPackages = with pkgs; [
    (python3.withPackages (ps: with ps; [openrazer]))
    razergenie
  ];
}
