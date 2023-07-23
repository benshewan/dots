{ stdenv
, fetchFromGitHub
, buildNpmPackage
, nodejs_16
, electron_16
, pkg-config
, cairo
, gobject-introspection
, python3
, ...
}:

let

  buildNpmPackage' = buildNpmPackage.override { nodejs = nodejs_16; };

  version = "1.5.2";
  src = fetchFromGitHub {
    owner = "JezerM";
    repo = "nody-greeter";
    rev = "refs/tags/${version}";
    sha256 = "w4aEjqBVjjZMH1MkogJ8Shxbm6vE9gXxsypLeiYKxm8=";
    fetchSubmodules = true;
  };

in
buildNpmPackage' {
    pname = "nody-greeter";
    inherit src version;

    makeCacheWritable = true;
    npmDepsHash = "sha256-wcFNeeCnxc4jh9ybpWZyFKnCH3oGgDl+Wv7J0qX5/GI=";

    buildInputs = [ nodejs_16 python3 electron_16 pkg-config cairo gobject-introspection ];
    nativeBuildInputs = [ pkg-config cairo gobject-introspection ];

    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    ELECTRON_OVERRIDE_DIST_PATH = "${electron_16}/bin/";

    buildPhase = ''
      ln -sf ${electron_16}/lib/electron ./node_modules/electron/dist
      npm run rebuild
      npm run build
    '';

    installPhase = ''
      node make install --DEST_DIR $out --PREFIX /
    '';
  }