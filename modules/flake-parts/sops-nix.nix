{
  inputs,
  lib,
  ...
}: {
  flake-file.inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.system = {
    config,
    pkgs,
    ...
  }: {
    imports = [inputs.sops-nix.nixosModules.sops];

    environment.systemPackages = [pkgs.sops pkgs.age];

    sops = {
      # Per-host post-quantum age identity, provisioned out-of-band.
      # Generate/install with: age-keygen -pq -o /var/lib/sops-nix/key.txt
      age.keyFile = "/var/lib/sops-nix/key.txt";

      # All shared secrets live in one encrypted file in this repo.
      defaultSopsFile = ../../secrets/common.yaml;
      validateSopsFiles = true;
    };
  };
}
