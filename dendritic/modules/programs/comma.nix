{inputs, ...}: {
  flake-file.inputs = {
    nix-index-database.url = "github:Mic92/nix-index-database";
  };

  flake.modules.nixos."programs/comma" = {...}: {
    imports = [inputs.nix-index-database.nixosModules.nix-index];
    programs = {
      # Enable Comma, a tool to easily run any binary
      nix-index-database.comma.enable = true;
      command-not-found.enable = false;
    };
  };
}
