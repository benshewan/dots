{
  stdenv,
  pkgs,
  ...
}: let
  version = "1.05.00";
  src = pkgs.fetchurl {
    url = "https://hanwhavisionamerica.com/download/48379";
    sha256 = "sha256-LYcniRFPI1867ronEk2iuEnIpgBw6O/qiFvNsjpMkdw=";
  };
in
  stdenv.mkDerivation {
    pname = "wisenet-viewer";
    inherit src version;

    nativeBuildInputs = with pkgs; [
      dpkg
      unzip
      autoPatchelfHook

      ffmpeg_4.lib
      gcc-unwrapped.lib
      libsForQt5.qt5.qtbase.out
      libsForQt5.qt5.qtdeclarative.out
      libsForQt5.qt5.qtmultimedia.out
      libusb1.out

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
      xorg.libXtst
      libpng
      libGL
      libpulseaudio
      glib
      nss
      nspr
      zlib
      krb5
      xorg.libxcb
      pango
      cairo
      gdk-pixbuf
      unixODBC
      atkmm
      gtk3.out
      psqlodbc
    ];

    unpackPhase = ''
      unzip $src
      ls -la
      dpkg-deb -x ./*.deb .
    '';

    installPhase = ''
      mkdir -p $out/etc
      mkdir -p $out/opt
      mkdir -p $out/bin
      mv usr/* $out
      mv etc/* $out/etc
      mv opt/* $out/opt

      substituteInPlace $out/share/applications/wisenet-viewer.desktop \
        --replace "/opt/HanwhaVision/WisenetViewer/WisenetViewer.sh" "$out/opt/HanwhaVision/WisenetViewer/WisenetViewer.sh" \

      substituteInPlace $out/opt/HanwhaVision/WisenetViewer/WisenetViewer.sh \
        --replace '$(dirname "$(readlink -f "$0")")' "$out/opt/HanwhaVision/WisenetViewer" \

      ln -s $out/opt/HanwhaVision/WisenetViewer/WisenetViewer.sh $out/bin/wisenet-viewer
    '';
  }
