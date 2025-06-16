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

  meta = with pkgs.lib; {
    description = "keylightd is a small system daemon for Framework laptops that listens to keyboard and touchpad input, and turns on the keyboard backlight while either is being used.";
    homepage = "https://github.com/piotr-yuxuan/keylightd";
    license = licenses.mit; # Or the appropriate license
    maintainers = [maintainers.benshewan];
    platforms = platforms.linux;
  };
}
