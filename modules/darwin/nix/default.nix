{
  pkgs,
  lib,
  inputs,
  ...
}: {
  nix.channel.enable = false;
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.warn-dirty = false;

  # Hard Link optimization
  nix.optimise.automatic = true;

  # Garbage collect
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 7d";
  };

  nix.package = pkgs.nixVersions.latest;
  nix.settings.trusted-users = ["root" "@admin"];

  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix.registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);
}
