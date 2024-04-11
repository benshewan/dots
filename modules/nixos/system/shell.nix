{
  outputs,
  config,
  pkgs,
  ...
}: {
  # Add support for ~/.local/bin
  environment.localBinInPath = true;

  # Shell
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;
  environment.shellAliases = {
    reboot = "systemctl reboot";
    nix-switch = "sudo nixos-rebuild switch --flake ${outputs.flake-path}#${config.networking.hostName}";
    # home-switch = "home-manager switch --flake ${outputs.flake-path}#${outputs.username}@${config.networking.hostName}";
  };
}
