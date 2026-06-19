{
  pkgs ? import <nixpkgs> {},
  stdenv,
  lib,
  ...
}:
let
  volkMeta = stdenv.mkDerivation {
    pname = "volk-meta";
    version = "1.4.350";
    src = pkgs.fetchFromGitHub {
      owner = "zeux";
      repo = "volk";
      rev = "1.4.350";
      hash = "sha256-7JsOWhMTnxeJfsTVgnnHQt5gYJ8tqELT+s3VDHTPof8=";
    };
    nativeBuildInputs = with pkgs; [cmake];
    buildInputs = with pkgs; [vulkan-headers];
    cmakeFlags = ["-DCMAKE_BUILD_TYPE=Release"];
    installPhase = ''
      mkdir -p $out/lib $out/include
      install -Dm644 libvolk.a $out/lib/
      install -Dm644 ../volk.h $out/include/
      mkdir -p $out/lib/cmake/volk
      cat > $out/lib/cmake/volk/volkConfig.cmake <<EOF
      add_library(volk::volk STATIC IMPORTED)
      set_target_properties(volk::volk PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "$out/include"
        IMPORTED_LOCATION "$out/lib/libvolk.a"
      )
      EOF
    '';
  };

  ncnnSrc = pkgs.fetchFromGitHub {
    owner = "Tencent";
    repo = "ncnn";
    rev = "e956fbf9bd97fe945df35d736747dc816f8b5f42";
    hash = "sha256-Kflx8MXFenfRmKuE9r5rnLb9Ze9D8CD0isC2A+P/3iQ=";
  };
in
stdenv.mkDerivation {
  pname = "gemini-watermark-tool";
  version = "0.3.1";

  src = pkgs.fetchFromGitHub {
    owner = "allenk";
    repo = "GeminiWatermarkTool";
    rev = "v0.3.1";
    hash = "sha256-uH8x3Jc9i2d8V2w96vHpkaUMLy22yVvHaHnDhTBDbK0=";
  };

  postUnpack = ''
    mkdir -p $sourceRoot/external/ncnn/ncnn-20260113-src
    cp -r ${ncnnSrc}/* $sourceRoot/external/ncnn/ncnn-20260113-src/
    chmod -R u+w $sourceRoot/external/ncnn/ncnn-20260113-src
  '';

  nativeBuildInputs = with pkgs; [
    cmake
    ninja
    pkg-config
    makeWrapper
  ];

  buildInputs = with pkgs; [
    opencv4
    fmt
    cli11
    spdlog
    vulkan-headers
    vulkan-loader
    volkMeta
    glslang
    shaderc
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DBUILD_GUI=OFF"
    "-DENABLE_AI_DENOISE=ON"
    "-DNCNN_SYSTEM_GLSLANG=ON"
  ];

  postFixup = ''
    mv $out/bin/GeminiWatermarkTool $out/bin/.GeminiWatermarkTool-wrapped
    makeWrapper $out/bin/.GeminiWatermarkTool-wrapped $out/bin/gemini-watermark-tool \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [pkgs.vulkan-loader]}
    ln -s gemini-watermark-tool $out/bin/GeminiWatermarkTool
  '';

  meta = with lib; {
    description = "Remove Gemini visible watermarks from images using reverse alpha blending";
    homepage = "https://github.com/allenk/GeminiWatermarkTool";
    license = licenses.mit;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = [maintainers.benshewan];
  };
}
