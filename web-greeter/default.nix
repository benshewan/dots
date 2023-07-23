{ stdenv
, fetchurl
, dpkg
, linkFarm
, writeText
, lightdm
, python311
, xorg
, gobject-introspection
, ...
}:

let

  version = "3.5.2";

  src = fetchurl {
    url = "https://github.com/JezerM/web-greeter/releases/download/3.5.2/web-greeter-3.5.2-debian.deb";
    sha256 = "1prwv23dv114mgcjxs65pm541zg08ya7c7pz5nq08dnkh35pr6w1";
  };

  defaultConfig = writeText "web-greeter.conf"
    ''
      branding:
          background_images_dir: $out/share/backgrounds
          logo_image: $out/share/web-greeter/themes/default/img/antergos-logo-user.png
          user_image: $out/share/web-greeter/themes/default/img/antergos.png

      greeter:
          debug_mode: False
          detect_theme_errors: True
          screensaver_timeout: 300
          secure_mode: True
          theme: gruvbox
          icon_theme:
          time_language:

      layouts:
          - us
          - latam

      features:
          battery: False
          backlight:
              enabled: False
              value: 10
              steps: 0
    '';

in
stdenv.mkDerivation {
  pname = "lightdm-web-greeter";
  inherit src version;

  # WEB_GREETER_CONFIG = "$out/etc/lightdm/web-greeter.yml";

  buildInputs = [
    lightdm
    (python311.withPackages (ps: with ps; [
      pygobject3
      pyqt5
      ruamel-yaml # Not actually installing as deps
      pyinotify
      pyqtwebengine
    ]))
    gobject-introspection
    xorg.libxcb
    xorg.libX11
  ];
  nativeBuildInputs = [ dpkg ];

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  # cp ${web-greeter-config} $out/etc/lightdm/web-greeter.yml
  # ${defaultConfig} > $out/etc/lightdm/web-greeter.yml
  installPhase = ''
    mkdir -p $out/etc
    mv usr/* $out
    mv etc/* $out/etc

    substituteInPlace $out/bin/web-greeter \
      --replace "/usr/lib/web-greeter" "$out/lib/web-greeter" \

    substituteInPlace $out/lib/web-greeter/config.py \
      --replace "/usr/share/web-greeter/themes/" "$out/share/web-greeter/themes/" \


    substituteInPlace $out/share/applications/web-greeter.desktop \
      --replace "/usr/bin/web-greeter" "web-greeter" \
      --replace "/usr/share/icons" "${placeholder "out"}/share/icons"
  '';

  # passthru.xgreeters = linkFarm "lightdm-web-greeter-xgreeters" [{
  #   path = "${lightdm-web-greeter}/share/applications/web-greeter.desktop";
  #   name = "web-greeter.desktop";
  # }];

}
