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

  buildInputs = with pkgs; [
    cmake
    vcpkg

    asio
    protobuf
    zlib
    cxxopts
    spdlog
  ];

  postPatch = ''
    cd server-core
    cp -r * ../
  '';

  cmakeFlags = [
    # "-DENABLE_VCPKG=OFF"
  ];

  buildPhase = ''
    cmake --preset linux-Release
    cmake --build --preset linux-Release
    ls -la /
  '';

  installPhase = ''
    mkdir -p $out/bin
    ls -la server-core
    exit 0
  '';
}
