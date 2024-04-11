{
  keylightd-config = import ./keylightd.nix;
  printing-config = import ./printing;
  virtualization-config = import ./virtualization;
  xserver-config = import ./xserver;
  upower-config = import ./upower.nix;
  ssh-config = import ./ssh.nix;
}
