{inputs, ...}: {
  flake-file.inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
  };

  imports = [inputs.flake-parts.flakeModules.modules];
}
