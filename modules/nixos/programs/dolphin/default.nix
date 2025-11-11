{pkgs, ...}: {
  environment.systemPackages =
    (with pkgs; [
      taglib
      ffmpegthumbnailer
    ])
    ++ (with pkgs.kdePackages; [
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
