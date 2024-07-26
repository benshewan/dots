{lib, ...}: final: prev: {
  mongodb-compass = prev.mongodb-compass.overrideAttrs (old: {
    postFixup = ''
      # Make sure that libGLESv2 and libvulkan are found by dlopen in both chromium binary and ANGLE libGLESv2.so.
      # libpci (from pciutils) is needed by dlopen in angle/src/gpu_info_util/SystemInfo_libpci.cpp
      for chromiumBinary in "$out/lib/mongodb-compass/MongoDB\ Compass" "$out/lib/mongodb-compass/libGLESv2.so"; do
        patchelf --set-rpath "${lib.makeLibraryPath (with prev; [libGL vulkan-loader pciutils])}:$(patchelf --print-rpath "$chromiumBinary")" "$chromiumBinary"
      done
    '';
  });
}
