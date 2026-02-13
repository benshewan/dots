{
  lib,
  inputs,
  config,
  pkgs,
  ...
}: {
  # NixOS Stuff
  imports = [inputs.determinate.nixosModules.default];

  programs.nix-ld.enable = true;

  nix.channel.enable = false;
  nix.settings.use-xdg-base-directories = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.auto-optimise-store = true;
  nix.settings.warn-dirty = false;
  programs.nh = {
    enable = true;
    flake = "/home/${config.night-sky.user.name}/.nix/";
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep 5 --keep-since 3d";
    };
  };
  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix.registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  nix.generateRegistryFromInputs = true;
  nix.generateNixPathFromInputs = true;
  nix.linkInputs = true;
  # nixpkgs.overlays = builtins.attrValues outputs.overlays ++ [inputs.nur.overlay];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).

  system.stateVersion = "23.05"; # Did you read the comment?
}
