{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [inputs.sops-nix.nixosModules.sops];

  environment.systemPackages = [pkgs.ssh-to-age];

  sops = {
    defaultSopsFile = "${(lib.snowfall.fs.get-file "secrets")}/secrets.yaml";
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    age.keyFile = "/var/lib/sops-nix/key.txt";
    # This will generate a new key if the key specified above does not exist
    age.generateKey = true;
  };
}
