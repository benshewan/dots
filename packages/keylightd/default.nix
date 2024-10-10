{pkgs ? import <nixpkgs> {}}:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "keylightd";
  version = "1.1.0";
  cargoLock.lockFile = "${src}/Cargo.lock";
  src = pkgs.fetchFromGitHub {
    owner = "piotr-yuxuan";
    repo = "keylightd";
    rev = "b7b17e3ac9402cbaac9ca9192c33755f6e8394a6";
    sha256 = "sha256-QFsbd3npKQkiNuv9xxU0erKClbDACiu8fg7NNecsqz8=";
  };
}
