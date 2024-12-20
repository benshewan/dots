{
  inputs,
  config,
  namespace,
  lib,
  osConfig ? null,
  ...
}: {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  sops = {
    age.sshKeyPaths = ["${config.${namespace}.user.home}/.ssh/id_ed25519"];
    defaultSopsFile = "${(lib.snowfall.fs.get-file "secrets")}/secrets.yaml";
  };
}
