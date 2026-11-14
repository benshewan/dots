{
  inputs,
  lib,
  ...
}: {
  imports = [inputs.flake-file.flakeModules.default];
  flake-file.inputs = {
    # make sure you add flake-file dependency.
    flake-file.url = lib.mkDefault "github:denful/flake-file";
  };
  flake-file.outputs = ''
    inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } ({...}: {
      imports = [
        (inputs.import-tree ./modules)
        (inputs.import-tree (it: it.matchNot "/[^/]+/hardware-configuration\\.nix$") ./machines)
      ];
    })
  '';
}
