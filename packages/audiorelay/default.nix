{
  stdenv,
  pkgs,
  ...
}: let
  version = "0.27.5";
  src = pkgs.fetchurl {
    url = "https://dl.audiorelay.net/setups/linux/audiorelay-${version}.tar.gz";
    sha256 = "sha256-xIVBOaS9Iee/eIGntuIevEz+gjKGeD1Pua1L9O346Mc=";
  };
in
  stdenv.mkDerivation {
    pname = "audiorelay";
    inherit src version;

    # We are using steam-run as it provides a robust FHS environment
    # that is proven to work for this pre-packaged application.
    nativeBuildInputs = with pkgs; [
      makeWrapper
      steam-run
    ];

    buildInputs = with pkgs; [
      alsa-lib
      alsa-plugins
      gtk3
      pipewire
      pulseaudioFull # Kept for good measure, as steam-run might use it.
    ];

    unpackPhase = ''
      tar -xzf $src
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      mkdir -p $out/share/audiorelay
      mv * $out/share/audiorelay/

      makeWrapper "${pkgs.steam-run}/bin/steam-run" $out/bin/audiorelay \
        --add-flags "$out/share/audiorelay/bin/AudioRelay" \
        --set-default PULSE_SERVER "unix:\$XDG_RUNTIME_DIR/pulse/native" \

      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Stream audio from your PC to your phone";
      homepage = "https://audiorelay.net/";
      license = licenses.unfree;
      platforms = platforms.linux;
      maintainers = with maintainers; [benshewan];
    };
  }
