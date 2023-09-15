{
  description = "A declarative development enviroment for FreeCore";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ]; # "aarch64-linux" not supported
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
      });
    in
    {
      devShells = forEachSupportedSystem ({ pkgs }: {
        default =
          pkgs.mkShell {
            packages = (with pkgs; [ nodejs mongodb ]) ++ (with pkgs.nodePackages; [ nodemon ]);
            shellHook = ''
              trap \
                "
                  # check if we're the only instance now running
                  # if it returns 0 as status code we know that there's other instances running
                  ls -1 .database/locks | grep -qv $$ && { rm .database/locks/$$; exit 0; }
                  # we can now that the only lockfile is ours
                  # kills mongod
                  pkill mongod
                  rm .database/locks/$$
                " EXIT

              # if another instance is running we just exit
              if [[ ! -z "$(ls .database/locks)" ]]; then
                # but we will add our own lock to tell the main instance that we're running
                touch .database/locks/$$
              else
                mkdir -p ~/.parallel && touch ~/.parallel/will-cite

                mkdir -p .database/locks 2> /dev/null
                nohup mongod --dbpath=.database > mongo.log 2>&1 &

                touch .database/locks/$$
              fi
            '';
          };
      });
    };
}
