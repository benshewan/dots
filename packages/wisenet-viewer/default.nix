{
  stdenv,
  pkgs ? import <nixpkgs> {},
  lib,
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

    desktopItem = pkgs.makeDesktopItem {
      name = "wisenet-viewer";
      exec = "wisenet-viewer";
      comment = "Hanwha Vision Wisenet Viewer";
      desktopName = "Wisenet Viewer";
      genericName = "Video Surveillance";
      categories = ["Network"];
    };

    unpackPhase = ''
      runHook preUnpack
      unzip $src
      dpkg-deb -x ./*.deb .
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin

      if [ -d ./usr ]; then cp -r ./usr/* $out/; fi
      if [ -d ./etc ]; then cp -r ./etc $out/; fi
      if [ -d ./opt ]; then cp -r ./opt $out/; fi

      # Update the hardcoded path in the launcher script to point to its new home in the Nix store.
      substituteInPlace $out/opt/HanwhaVision/WisenetViewer/WisenetViewer.sh \
        --replace '$(dirname "$(readlink -f "$0")")' "$out/opt/HanwhaVision/WisenetViewer"

      # Create a symlink in $out/bin so the user can run `wisenet-viewer` from their terminal.
      ln -s $out/opt/HanwhaVision/WisenetViewer/WisenetViewer.sh $out/bin/wisenet-viewer

      # Install the generated .desktop file to the correct location.
      install -Dm644 $desktopItem/share/applications/* -t $out/share/applications

      runHook postInstall
    '';

    meta = with lib; {
      description = "A viewer for Hanwha Vision (formerly Samsung Techwin) security products";
      homepage = "https://hanwhavisionamerica.com/";
      sourceProvenance = [sourceTypes.binaryNativeCode];
      license = licenses.unfree;
      platforms = platforms.linux;
      maintainers = [maintainers.benshewan];
    };
  }
