{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dpkg,
  wrapGAppsHook,
  alsa-lib,
  browserpass,
  bukubrow,
  cairo,
  cups,
  dbus,
  dbus-glib,
  ffmpeg,
  fontconfig,
  freetype,
  fx-cast-bridge,
  glib,
  glibc,
  gnome-browser-connector,
  gtk3,
  harfbuzz,
  libcanberra,
  libdbusmenu,
  libdbusmenu-gtk3,
  libglvnd,
  libjack2,
  libkrb5,
  libnotify,
  libpulseaudio,
  libva,
  lyx,
  mesa,
  nspr,
  nss,
  opensc,
  pango,
  pciutils,
  pipewire,
  plasma5Packages,
  sndio,
  speechd,
  tridactyl-native,
  udev,
  uget-integrator,
  vulkan-loader,
  xdg-utils,
  xorg,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "mercury-browser";
  version = "115.4.0";

  src = fetchurl {
    url = "https://github.com/Alex313031/Mercury/releases/download/v.${version}/mercury-browser_${version}_amd64.deb";
    hash = "sha256-78b2QEgf312TDBIy4lXzYUBtTfdNui3VJBbyDfXqOtc=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    wrapGAppsHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    alsa-lib
    browserpass
    bukubrow
    cairo
    cups
    dbus
    dbus-glib
    ffmpeg
    fontconfig
    freetype
    fx-cast-bridge
    glib
    glibc
    gnome-browser-connector
    gtk3
    harfbuzz
    libcanberra
    libdbusmenu
    libdbusmenu-gtk3
    libglvnd
    libjack2
    libkrb5
    libnotify
    libpulseaudio
    libva
    lyx
    mesa
    nspr
    nss
    opensc
    pango
    pciutils
    pipewire
    plasma5Packages.plasma-browser-integration
    sndio
    speechd
    tridactyl-native
    udev
    uget-integrator
    vulkan-loader
    xdg-utils
    xorg.libxcb
    xorg.libX11
    xorg.libXcursor
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXtst
    xorg.libXxf86vm
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r usr/* $out

    substituteInPlace $out/share/applications/mercury-browser.desktop \
      --replace StartupWMClass=mercury StartupWMClass=mercury-default \
    addAutoPatchelfSearchPath $out/lib/mercury
    substituteInPlace $out/bin/mercury-browser \
      --replace 'export LD_LIBRARY_PATH' "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:${lib.makeLibraryPath buildInputs}:$out/lib/mercury" \
      --replace /usr $out

    runHook postInstall
  '';

  postInstall = let
    customjs-loader = fetchFromGitHub {
      owner = "xiaoxiaoflood";
      repo = "firefox-scripts";
      rev = "b013243f1916576166a02d816651c2cc6416f63e";
      sha256 = "sha256-Zp1pRMqgAM3Xh3JCkAC0hWp2Gl2phkyAwJ8KB2tA9jE=";
    };
  in ''
    mkdir -p $out/lib/firefox/browser/defaults/preferences
     cp ${customjs-loader}/installation-folder/config.js $out/lib/firefox/config.js
     cp ${customjs-loader}/installation-folder/config-prefs.js $out/lib/firefox/browser/defaults/preferences/config-prefs.js
  '';

  meta = with lib; {
    description = "Compiler-optimized private Firefox fork";
    homepage = "https://thorium.rocks/mercury";
    sourceProvenance = with sourceTypes; [binaryNativeCode];
    license = licenses.unfree;
    platforms = ["x86_64-linux"];
    mainProgram = "mercury-browser";
  };
}
