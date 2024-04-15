{
  stdenv,
  fetchurl,
  unzip,
  dpkg,
  buildFHSUserEnv,
  ...
}: let
  version = "1.05.00";

  src = fetchurl {
    url = "https://hanwhavisionamerica.com/download/48379";
    sha256 = "sha256-LYcniRFPI1867ronEk2iuEnIpgBw6O/qiFvNsjpMkdw=";
  };
  wisenet-viewer-environment = stdenv.mkDerivation {
    pname = "wisenet-viewer-environment";
    inherit src version;

    nativeBuildInputs = [dpkg unzip];

    unpackPhase = ''
      unzip $src
      ls -la
      dpkg-deb -x ./*.deb .
    '';

    installPhase = ''
      mkdir -p $out/etc
      mkdir -p $out/opt
      mv usr/* $out
      mv etc/* $out/etc
      mv opt/* $out/opt

      substituteInPlace $out/share/applications/wisenet-viewer.desktop \
        --replace "/opt/HanwhaVision/WisenetViewer/WisenetViewer.sh" "$out/opt/HanwhaVision/WisenetViewer/WisenetViewer.sh" \

      substituteInPlace $out/opt/HanwhaVision/WisenetViewer/WisenetViewer.sh \
        --replace '$(dirname "$(readlink -f "$0")")' "$out/opt/HanwhaVision/WisenetViewer" \
    '';
  };
in (buildFHSUserEnv {
  name = "wisenet-viewer";
  targetPkgs = p:
    with p; [
      wisenet-viewer-environment

      fontconfig
      freetype
      xorg.libX11
      libusb1.out
      xorg.xcbutilwm
      xorg.xcbutilimage
      xorg.xcbutil
      xorg.xcbutilkeysyms
      xorg.xcbutilrenderutil
      xorg.libXcomposite
      xorg.libXdamage
      xorg.libXrender
      xorg.libXrandr
      xorg.libXcursor
      xorg.libXi
      xorg.libXtst
      xorg.libXfixes
      alsa-lib
      expat
      dbus
      libxkbcommon
      libpng
      libGL
      libpulseaudio
      glib
      zlib
      krb5
      xorg.libxcb
      nss
      nspr
    ];
  runScript = "/opt/HanwhaVision/WisenetViewer/WisenetViewer.sh";
})
