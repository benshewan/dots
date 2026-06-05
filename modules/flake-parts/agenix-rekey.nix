{
  inputs,
  self,
  lib,
  config,
  ...
} @ flake: let
  enableSecrets = flake.config.flake.enableSecrets;

  ageConfigModule = {
    age.rekey.masterIdentities = [(inputs.secrets + "/yubikey-93302b8a.pub")];
    age.rekey.storageMode = "derivation";
    age.rekey.cacheDir = "/var/tmp/agenix-rekey/\"$UID\"";
    nix.settings.extra-sandbox-paths = ["/var/tmp/agenix-rekey"];
  };
in {
  options.flake.enableSecrets = lib.mkOption {
    type = lib.types.bool;
    default = builtins.pathExists (inputs.secrets + "/yubikey-93302b8a.pub");
    description = "Auto-detected from secrets input. Override-input to stub → auto-disabled.";
  };

  config = {
    flake-file.inputs = {
      agenix.url = "github:ryantm/agenix";
      agenix-rekey.url = "github:oddlama/agenix-rekey";
      secrets = {
        url = "git+ssh://git@github.com/benshewan/nix-secrets";
        flake = false;
      };
    };

    flake.agenix-rekey = lib.mkIf enableSecrets (inputs.agenix-rekey.configure {
      userFlake = self;
      nixosConfigurations = self.nixosConfigurations;
      darwinConfigurations = self.darwinConfigurations or {};
      homeConfigurations = self.homeConfigurations or {};
      # Example for colmena:
      # nixosConfigurations = ((colmena.lib.makeHive self.colmena).introspect (x: x)).nodes;
    });

    flake.modules.nixos.system = {
      pkgs,
      lib,
      config,
      ...
    }: {
      imports = lib.optionals enableSecrets [
        inputs.agenix.nixosModules.default
        inputs.agenix-rekey.nixosModules.default
        ageConfigModule
      ];
      # This adds support for rekeying when system has just been bootstrapped and the rest hasn't been loaded yet
      config = {
        nixpkgs.overlays = [inputs.agenix-rekey.overlays.default];
        environment.systemPackages = [pkgs.agenix-rekey];
        systemd.tmpfiles.rules = [
          "d /var/tmp/agenix-rekey 1777 root root"
        ];
      };
    };
  };

  # Works, but I don't like having to use my users ssh key to deal with secret files.
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
  #   age = {
  #     secretsDir = "${config.xdg.dataHome}/agenix/agenix";
  #     secretsMountPoint = "${config.xdg.dataHome}/agenix/agenix.d";
  #     identityPaths = ["/home/${flake.config.flake.meta.user.username}/.ssh/id_ed25519"];
  #   };
  # };
}
