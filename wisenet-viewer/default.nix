{ stdenv
, fetchurl
, dpkg
, ...
}:

let

  version = "1.04.00";

  src = builtins.fetchZip {
    url = "https://hanwhavisionamerica.com/download/48379";
    sha256 = "1prwv23dv114mgcjxs65pm541zg08ya7c7pz5nq08dnkh35pr6w1";
  };
in
stdenv.mkDerivation {
  pname = "wisenet-viewer";
  inherit src version;

  nativeBuildInputs = [ dpkg ];

  unpackPhase = ''
    dpkg-deb -x $src .
  '';


  installPhase = ''
    mkdir -p $out/etc
    mkdir -p $out/opt
    mv usr/* $out
    mv etc/* $out/etc
    mv opt/* $out/opt

    substituteInPlace $out/share/applications \
      --replace "/opt/HanwhaVision/WisenetViewer/WisenetViewer.sh" "$out/opt/HanwhaVision/WisenetViewer/WisenetViewer.sh" \

    substituteInPlace $out/opt//HanwhaVision/WisenetViewer/WisenetViewer.sh \
      --replace "#!/bin/sh" "#!/usr/bin/env sh" \


    substituteInPlace $out/share/applications/web-greeter.desktop \
      --replace "/usr/bin/web-greeter" "web-greeter" \
      --replace "/usr/share/icons" "${placeholder "out"}/share/icons"
  '';

  # passthru.xgreeters = linkFarm "lightdm-web-greeter-xgreeters" [{
  #   path = "${lightdm-web-greeter}/share/applications/web-greeter.desktop";
  #   name = "web-greeter.desktop";
  # }];

}