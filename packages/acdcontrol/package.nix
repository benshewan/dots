{
  pkgs ? import <nixpkgs> {},
  stdenv,
}:
stdenv.mkDerivation {
  pname = "acdcontrol";
  version = "1.0.0";
  src = pkgs.fetchFromGitHub {
    owner = "yhaenggi";
    repo = "acdcontrol";
    rev = "6ebc39a9c9c954cc31eeb28fbe08370e5228b66c";
    sha256 = "sha256-P+qL8HZd4MbKJkQnaDJSmTihZ0Gzt9bo2ciOcXd/ymA=";
  };

  buildPhase = ''
    make
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp acdcontrol $out/bin
  '';
}
