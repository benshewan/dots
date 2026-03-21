{
  inputs,
  lib,
  ...
}: {
  imports = [inputs.flake-file.flakeModules.default inputs.flake-file.flakeModules.nix-auto-follow];
  flake-file.inputs = {
    # make sure you add flake-file dependency.
    flake-file.url = lib.mkDefault "github:vic/flake-file";
  };
  flake-file.prune-lock.enable = true;
  flake-file.outputs = ''
    inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules)
  '';
}
