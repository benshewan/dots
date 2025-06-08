{
  pkgs ? import <nixpkgs> {},
  stdenv,
}:
stdenv.mkDerivation {
  pname = "audio-share";
  version = "0.3.4";
  src = pkgs.fetchFromGitHub {
    owner = "mkckr0";
    repo = "audio-share";
    rev = "342751fe675367483170b002ec6054e243966dc0";
    sha256 = "sha256-EuANnVwxeEzLhp8j/okQ2f1FSt4U61UK9kersgETBpQ=";
  };
  sourceRoot = "source/server-core";

  nativeBuildInputs = with pkgs; [
    cmake
    pkg-config
  ];

  buildInputs = with pkgs; [
    vcpkg
    asio
    protobuf
    zlib
    cxxopts
    spdlog
    pipewire
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-warn 'find_package(Protobuf CONFIG REQUIRED)' 'find_package(Protobuf REQUIRED)' \
      --replace-warn 'find_package(asio CONFIG REQUIRED)' "" \
      --replace-warn 'asio::asio' ""
  '';

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_PREFIX_PATH=${pkgs.protobuf}:${pkgs.cxxopts}:${pkgs.spdlog}"
    "-DASIO_INCLUDE_DIR=${pkgs.asio}/include"
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m 755 as-cmd $out/bin/audio-share
    runHook postInstall
  '';
}
