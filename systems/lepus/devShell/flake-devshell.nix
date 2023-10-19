{
  description = "A declarative development enviroment for FreeCore";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.devshell.url = "github:numtide/devshell";

  outputs = {
    self,
    flake-utils,
    devshell,
    nixpkgs,
  }:
    flake-utils.lib.eachDefaultSystem (system: {
      devShell = let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [devshell.overlays.default];
        };
      in
        pkgs.devshell.mkShell {
          packages = [
            "nodejs"
            "mongodb"
            "mongodb-tools"
            "nodePackages.nodemon"
          ];
          env = [
            {
              name = "PATH";
              prefix = "${pkgs.nodejs}";
            }
          ];
          commands = [
            {
              name = "start";
              help = "Start the FreeCore framework";
              command = ''npm --prefix $PRJ_ROOT/framework run start'';
            }
            {
              name = "start:watch";
              help = "Start the FreeCore framework (in watch mode)";
              command = "npm --prefix $PRJ_ROOT/framework run start:watch";
            }
          ];

          serviceGroups.database = {
            description = "monogdb in the background";
            services.mongodb = {
              command = "mongod --dbpath=.database > mongo.log 2>&1 &";
            };
          };
        };
    });
}
