{pkgs, ...}: {
  environment.systemPackages =
    (with pkgs; [
      taglib
      ffmpegthumbnailer
    ])
    ++ (with pkgs.libsForQt5; [
      dolphin
      ark
      baloo
      dolphin-plugins
      kdegraphics-thumbnailers
      kio
      kio-extras
      breeze-icons
    ]);
}
