{ stdenv
, fetchurl
, unzip
, dpkg
, ...
}:

let

  version = "1.04.00";

  src = fetchurl {
    url = "https://hanwhavisionamerica.com/download/48379";
    sha256 = "sha256-WTets2nGNFm7baNiBQq/2FW9N0s5jKRTFYTFet8LGKI=";
  };
in
stdenv.mkDerivation {
  pname = "wisenet-viewer";
  inherit src version;

  nativeBuildInputs = [ dpkg unzip ];

  unpackPhase = ''
    unzip $src
    dpkg-deb -x ./WisenetViewer_1.04.00_20230511.deb .
  '';


  installPhase = ''
    mkdir -p $out/etc
    mkdir -p $out/opt
    mv usr/* $out
    mv etc/* $out/etc
    mv opt/* $out/opt

    substituteInPlace $out/share/applications/wisenet-viewer.desktop \
      --replace "/opt/HanwhaVision/WisenetViewer/WisenetViewer.sh" "$out/opt/HanwhaVision/WisenetViewer/WisenetViewer.sh" \

    c $out/opt/HanwhaVision/WisenetViewer/WisenetViewer.sh \
      --replace "#!/bin/sh" "#!/usr/bin/env sh" \
      --replace "\$\(dirname \"\$\(readlink -f \"\$0\"\)\"\)" "$out/opt/HanwhaVision/WisenetViewer" \
  '';
}
