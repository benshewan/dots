{inputs, ...}: {
  imports = [
    inputs.nix-index-database.darwinModules.nix-index
  ];
  programs = {
    # Enable Comma, a tool to easily run any binary
    nix-index-database.comma.enable = true;
    # command-not-found.enable = false;
  };
}
