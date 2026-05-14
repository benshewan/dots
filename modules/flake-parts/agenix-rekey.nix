{
  inputs,
  self,
  lib,
  ...
} @ flake: let
  ageConfigModule = args @ {config, ...}: let
    # 2. Determine the hostname dynamically
    hostName =
      if args ? osConfig
      then args.osConfig.networking.hostName # We are inside a Home Manager module
      else config.networking.hostName; # We are inside a NixOS/Darwin system module
    path =
      if (lib.hasAttr "networking" config)
      then hostName
      else "${config.home.username}-${hostName}";
  in {
    age.rekey.masterIdentities = [../../secrets/yubikey-93302b8a.pub];
    age.rekey.storageMode = "local";
    age.rekey.localStorageDir = ../../. + "/secrets/rekeyed/${path}";
  };
in {
  flake-file.inputs = {
    agenix.url = "github:ryantm/agenix";
    agenix-rekey.url = "github:oddlama/agenix-rekey";
  };

  flake.agenix-rekey = inputs.agenix-rekey.configure {
    userFlake = self;
    nixosConfigurations = self.nixosConfigurations;
    darwinConfigurations = self.darwinConfigurations or {};
    homeConfigurations = self.homeConfigurations or {};
    # Example for colmena:
    # nixosConfigurations = ((colmena.lib.makeHive self.colmena).introspect (x: x)).nodes;
  };

  flake.modules.nixos.system = {pkgs, ...}: {
    imports = [
      inputs.agenix.nixosModules.default
      inputs.agenix-rekey.nixosModules.default
      ageConfigModule
    ];
    nixpkgs.overlays = [inputs.agenix-rekey.overlays.default];
  };

  # flake.modules.homeManager.system = {
  #   pkgs,
  #   osConfig,
  #   config,
  #   ...
  # }: {
  #   imports = [
  #     inputs.agenix.homeManagerModules.default
  #     inputs.agenix-rekey.homeManagerModules.default
  #     ageConfigModule
  #   ];
  #   home.packages = [pkgs.agenix-rekey];
  #   age = {
  #     secretsDir = "${config.xdg.dataHome}/agenix/agenix";
  #     secretsMountPoint = "${config.xdg.dataHome}/agenix/agenix.d";
  #     identityPaths = ["/home/${flake.config.flake.meta.user.username}/.ssh/id_ed25519"];
  #   };
  # };
}
