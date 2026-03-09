{
  lib,
  stdenv,
  pkgs ? import <nixpkgs> {},
}:
stdenv.mkDerivation {
  pname = "keylightc";
  version = "0.1.0";

  src = pkgs.fetchFromGitLab {
    owner = "mamarley";
    repo = "keylightc";
    rev = "6336fee6010dcab64a22a43e6866fd190cf8d51c";
    sha256 = "sha256-BQAgTHaaupUUjK3eQLZm+yt7bydckSx3eHPgh5XT8hQ="; # Replace with the actual hash
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/lib/systemd/system

    install -m 755 -D -t $out/bin/ keylightc
    install -m 644 -D -t $out/lib/systemd/system/ keylightc.service

    runHook postInstall
  '';

  meta = with lib; {
    description = "keylightc is a small system daemon for Framework laptops that listens to keyboard and touchpad input, and turns on the keyboard backlight while either is being used.";
    homepage = "https://gitlab.com/mamarley/keylightc";
    license = licenses.mit;
    maintainers = with maintainers; [benshewan];
    platforms = platforms.all;
  };
}
