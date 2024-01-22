{pkgs ? import <nixpkgs> {}}:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "keylightd";
  version = "1.1.0";
  cargoLock.lockFile = "${src}/Cargo.lock";
  src = pkgs.fetchFromGitHub {
    owner = "jonas-schievink";
    repo = "keylightd";
    rev = "933a4cf851009d4a8c1b4ce7725556d69d4b82db";
    sha256 = "sha256-lU5ddVRjiGts7IzkoL3CWJVtjoiBMIHRBxb/C0n+oqQ=";
  };
}
