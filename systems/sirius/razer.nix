{
  pkgs,
  outputs,
  ...
}: {
  hardware.openrazer.enable = true;
  hardware.openrazer.users = [outputs.username];
  environment.systemPackages = with pkgs; [razergenie];
}
