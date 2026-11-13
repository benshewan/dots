{inputs, config, ...}: let
  username = config.flake.meta.user.username;
in {
  flake-file.inputs = {
    helium = {
      url = "github:schembriaiden/helium-browser-nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.homeManager."programs/helium" = {
    pkgs,
    lib,
    config,
    ...
  }: {
    home.packages = [inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default];
  };

  # Preservation companion for "programs/helium" (auto-resolved by the
  # prefix). Whole profile dir, same rationale as .config/Code — Helium is
  # a Chromium fork and uses its app-id dir (net.imput = Imput, the fork's
  # maintainer), not ".config/helium".
  flake.modules.nixos."preservation/programs/helium" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username} = {
      directories = [
        ".config/net.imput.helium"
      ];
    };
  };
}
