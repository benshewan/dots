{
  stdenv,
  fetchurl,
  unzip,
  dpkg,
  buildFHSUserEnv,
  ...
}: let
  version = "1.04.00";

  src = fetchurl {
    url = "https://hanwhavisionamerica.com/download/48379";
    sha256 = "sha256-WTets2nGNFm7baNiBQq/2FW9N0s5jKRTFYTFet8LGKI=";
  };
  wisenet-viewer-environment = stdenv.mkDerivation {
    pname = "wisenet-viesenet-viewer-environwer";
    inherit src version;

    nativeBuildInputs = [dpkg unzip];

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
