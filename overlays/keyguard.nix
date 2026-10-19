{lib, ...}: final: prev: let
  version = "3.2.3";
  tag = "r20260916";

  # Official jpackage app images published on the GitHub release. These are the
  # exact artifacts produced by the upstream `createReleaseDistributable` Gradle
  # task (nixpkgs builds the same output from source), so repackaging them keeps
  # behaviour identical to the nixpkgs derivation while tracking the latest
  # release.
  sources = {
    x86_64-linux = {
      url = "https://github.com/AChep/keyguard-app/releases/download/${tag}/Keyguard-${version}-linux-x86_64.tar.gz";
      hash = "sha256-3ON0REil3dVoe0yAtNOvQOFtVCNQfD4XcAw7jmlhF98=";
    };
    aarch64-linux = {
      url = "https://github.com/AChep/keyguard-app/releases/download/${tag}/Keyguard-${version}-linux-aarch64.tar.gz";
      hash = "sha256-nodg8evTm2Dh9xb1f6rOlR8lwPYJuYc6OD1UVsozYzQ=";
    };
  };

  keyguard = final.stdenv.mkDerivation (finalAttrs: {
    pname = "keyguard";
    inherit version;

    src = final.fetchurl {inherit (sources.${final.stdenv.hostPlatform.system}) url hash;};

    nativeBuildInputs = [final.autoPatchelfHook];

    # Mirrors the runtime dependencies of the nixpkgs build; autoPatchelfHook
    # rewrites the RUNPATH of the bundled JRE and native libraries.
    buildInputs = [
      final.alsa-lib
      final.cups
      final.file
      final.fontconfig
      final.glib
      final.gtk3
      final.lcms2
      final.libglvnd
      final.libxinerama
      final.libxrandr
      final.libxcursor
      final.libxext
      final.libxrender
      final.libxtst
      final.libxxf86vm
    ];

    # The tarball already ships a desktop entry, a scalable icon and appstream
    # metainfo under share/, so nothing has to be generated here.

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp --recursive . $out/

      runHook postInstall
    '';

    meta = {
      description = "Alternative client for the Bitwarden platform, created to provide the best user experience possible";
      homepage = "https://github.com/AChep/keyguard-app";
      changelog = "https://github.com/AChep/keyguard-app/releases/tag/${tag}";
      mainProgram = "Keyguard";
      license = lib.licenses.unfree;
      maintainers = with lib.maintainers; [ilkecan];
      sourceProvenance = with lib.sourceTypes; [
        binaryBytecode
        binaryNativeCode # bundled JRE and native libraries
      ];
      platforms = lib.platforms.linux;
    };
  });
in
  lib.optionalAttrs prev.stdenv.hostPlatform.isLinux {
    inherit keyguard;
  }
