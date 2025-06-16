{pkgs, ...}: {
  # Add support for ~/.local/bin
  environment.localBinInPath = true;

  # Shell
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;
  environment.shellAliases = {
    reboot = "systemctl reboot";
    poweroff = "systemctl poweroff";
    # nix-switch = "sudo nixos-rebuild switch --flake ${outputs.src}#${config.networking.hostName}";
    # home-switch = "home-manager switch --flake ${outputs.src}#${config.night-sky.user.name}@${config.networking.hostName}";
  };
}
