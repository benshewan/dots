{
  keylightd = import ./keylightd.nix;
  printing = import ./printing;
  virtualization = import ./virtualization;
  xserver = import ./xserver;
  upower = import ./upower.nix;
  ssh = import ./ssh.nix;
  flatpak = import ./flatpak.nix;
  syncthing = import ./syncthing.nix;
}
