{
  pkgs,
  lib,
  inputs,
  ...
}: {
  monitors = [
    # Internal Monitor
    {
      name = "eDP-1";
      width = 2256;
      height = 1504;
      primary = true;
      scale = 1.566667;
    }

    # Work Monitors
    {
      name = "desc:Dell Inc. DELL P2417H KH0NG95K15KL";
      width = 1920;
      height = 1080;
      x = -1017;
      y = -1080;
    }
    {
      name = "desc:Dell Inc. DELL P2417H KH0NG95F0AMI";
      width = 1920;
      height = 1080;
      x = 903;
      y = -1080;
    }

    # Home Monitors
    {
      name = "desc:Lenovo Group Limited P24q-10 U4P00001";
      # rotate = 1;
      width = 2560;
      height = 1440;
      scale = 1.25;
      y = -1152;
      x = -2048;
    }
    {
      name = "desc:Dell Inc. AW3423DWF 58082S3";
      width = 3440;
      height = 1440;
      # Some combination of my garbo dock and alpha software makes this explode my computer
      # colorProfile = "hdr";
      refreshRate = 165;
      scale = 1.25;
      x = 0;
      y = -1152;
    }
  ];

  # TESTING

  # Enable xdg.mimeApps to manage default applications
  xdg.mimeApps.enable = true;

  # Configure default applications for specific MIME types and URL schemes
  xdg.mimeApps.defaultApplications = {
    # Browser files
    "text/html" = "firefox-devedition.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";

    # Text files
    "text/plain" = "org.kde.kate.desktop";
    "text/xml" = "org.kde.kate.desktop";
    "application/json" = "org.kde.kate.desktop";

    # Compressed files
    "application/zip" = "ark.desktop";
    "application/gzip" = "ark.desktop";
    "application/tar" = "ark.desktop";
    "application/bzip2" = "ark.desktop";
    "application/7z-compressed" = "ark.desktop";
    "application/rar" = "ark.desktop";
    "application/xz" = "ark.desktop";
    "application/bzip" = "ark.desktop";

    # Document files

    # Image files
    "image/jpeg" = "org.gnome.Loupe.desktop";
    "image/png" = "org.gnome.Loupe.desktop";
    # File browser
    "inode/directory" = "yazi.desktop";

    # Ebook files
    "application/epub+zip" = "com.github.johnfactotum.Foliate.desktop";
    "application/x-mobipocket-ebook" = "com.github.johnfactotum.Foliate.desktop";
    "application/vnd.amazon.mobi8-ebook" = "com.github.johnfactotum.Foliate.desktop";
    "application/x-fictionbook+xml" = "com.github.johnfactotum.Foliate.desktop";
    "application/x-zip-compressed-fb2" = "com.github.johnfactotum.Foliate.desktop";
    "application/vnd.comicbook+zip" = "com.github.johnfactotum.Foliate.desktop";
    "x-scheme-handler/opds" = "com.github.johnfactotum.Foliate.desktop";

    # Video files
    "video/" = "mpv.desktop";
    "audio/" = "mpv.desktop";
    "application/ogg" = "mpv.desktop";
    "application/x-ogg" = "mpv.desktop";
    "application/mxf" = "mpv.desktop";
    "application/sdp" = "mpv.desktop";
    "application/smil" = "mpv.desktop";
    "application/x-smil" = "mpv.desktop";
    "application/streamingmedia" = "mpv.desktop";
    "application/x-streamingmedia" = "mpv.desktop";
    "application/vnd.rn-realmedia" = "mpv.desktop";
    "application/vnd.rn-realmedia-vbr" = "mpv.desktop";
    "application/x-extension-m4a" = "mpv.desktop";
    "application/x-extension-mp4" = "mpv.desktop";
    "application/vnd.ms-asf" = "mpv.desktop";
    "application/x-matroska" = "mpv.desktop";
    "application/x-ogm" = "mpv.desktop";
    "application/x-ogm-audio" = "mpv.desktop";
    "application/x-ogm-video" = "mpv.desktop";
    "application/x-shorten" = "mpv.desktop";
    "application/x-mpegurl" = "mpv.desktop";
    "application/vnd.apple.mpegurl" = "mpv.desktop";
    "application/x-cue" = "mpv.desktop";

    # Spreadsheets
    "application/clarisworks" = "calc.desktop";
    "application/csv" = "calc.desktop";
    "application/excel" = "calc.desktop";
    "application/msexcel" = "calc.desktop";
    "application/tab-separated-values" = "calc.desktop";
    "application/vnd.apache.parquet" = "calc.desktop";
    "application/vnd.apple.numbers" = "calc.desktop";
    "application/vnd.lotus-1-2-3" = "calc.desktop";
    "application/vnd.ms-excel" = "calc.desktop";
    "application/vnd.ms-excel.sheet.binary.macroEnabled.12" = "calc.desktop";
    "application/vnd.ms-excel.sheet.macroEnabled.12" = "calc.desktop";
    "application/vnd.ms-excel.template.macroEnabled.12" = "calc.desktop";
    "application/vnd.ms-works" = "calc.desktop";
    "application/vnd.oasis.opendocument.chart" = "calc.desktop";
    "application/vnd.oasis.opendocument.chart-template" = "calc.desktop";
    "application/vnd.oasis.opendocument.spreadsheet" = "calc.desktop";
    "application/vnd.oasis.opendocument.spreadsheet-flat-xml" = "calc.desktop";
    "application/vnd.oasis.opendocument.spreadsheet-template" = "calc.desktop";
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "calc.desktop";
    "application/vnd.openxmlformats-officedocument.spreadsheetml.template" = "calc.desktop";
    "application/vnd.stardivision.calc" = "calc.desktop";
    "application/vnd.stardivision.chart" = "calc.desktop";
    "application/vnd.sun.xml.calc" = "calc.desktop";
    "application/vnd.sun.xml.calc.template" = "calc.desktop";
    "application/x-123" = "calc.desktop";
    "application/x-dbase" = "calc.desktop";
    "application/x-dbf" = "calc.desktop";
    "application/x-dos_ms_excel" = "calc.desktop";
    "application/x-excel" = "calc.desktop";
    "application/x-gnumeric" = "calc.desktop";
    "application/x-iwork-numbers-sffnumbers" = "calc.desktop";
    "application/x-ms-excel" = "calc.desktop";
    "application/x-msexcel" = "calc.desktop";
    "application/x-quattropro" = "calc.desktop";
    "application/x-starcalc" = "calc.desktop";
    "application/x-starchart" = "calc.desktop";
    "text/comma-separated-values" = "calc.desktop";
    "text/csv" = "calc.desktop";
    "text/spreadsheet" = "calc.desktop";
    "text/tab-separated-values" = "calc.desktop";
    "text/x-comma-separated-values" = "calc.desktop";
    "text/x-csv" = "calc.desktop";
    # "application/pdf" = "zathura.desktop";
  };

  # -----------------------------------

  home.packages = with pkgs; [
    (prismlauncher.override {jdks = [jdk8 jdk17 jdk21 zulu25];})
    distrobox
    kdePackages.kate
    mpv
    bitwarden-desktop
    bottles
    wine
    # stable.kicad
    # plex-media-player
    # jellyfin-media-player
    # jetbrains.pycharm-professional
    moonlight-qt

    # Work stuff
    # teamviewer
    libreoffice-fresh
    gnome-network-displays
    # masterpdfeditor
    night-sky.wisenet-viewer
    inkscape
    krita
    obsidian

    # Messing around
    syncthingtray
    stable.handbrake

    # Audio
    qpwgraph
  ];

  programs.java = {
    enable = true;
    package = pkgs.jdk;
  };

  # services.flatpak.packages = [
  #   {
  #     appId = "com.parsecgaming.parsec";
  #     origin = "flathub";
  #   }
  #   # {
  #   #   appId = "com.getpostman.Postman";
  #   #   origin = "flathub";
  #   # }
  #   # {
  #   #   appId = "com.github.tchx84.Flatseal";
  #   #   origin = "flathub";
  #   # }
  # ];
  # home.file.".config/JetBrains/WebStorm${lib.versions.majorMinor pkgs.jetbrains.webstorm.version}/prettier" = {
  #   source = "${pkgs.nodePackages.prettier}/lib/node_modules/prettier";
  #   recursive = true;
  # };

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
    ];
  };
}
