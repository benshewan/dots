_: {
  flake.modules.nixos.system = {pkgs, ...}: {
    # Some default global commands
    environment.systemPackages = with pkgs; [
      vim # text editor
      git # downloading git code
      dig # look at dns records
      htop # check resource usage
      btop # check resource usage
      sysz # find systemd processes
      neofetch # check system stats
      bat # nice cat alternative
      wget # basic file downloading
      busybox # many basic linux utils
      ouch # unified file decompressor

      nix-prefetch-github
      nix-prefetch-git
      prefetch-npm-deps
      home-manager
    ];
  };
}
