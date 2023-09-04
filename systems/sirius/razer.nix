{ pkgs, username, ... }:
{
  hardware.openrazer.enable = true;
  hardware.openrazer.users = [ username ];
  environment.systemPackages = with pkgs; [ razergenie ];
}
