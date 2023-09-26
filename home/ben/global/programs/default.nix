{pkgs, ...}: {
  imports = [
    ./filebot
  ];

  # Programs
  home.packages = with pkgs; [
    # Development Tools
    mongodb-compass
    insomnia
    jetbrains.webstorm

    # Chromium browser of choice
    (vivaldi.override {
      proprietaryCodecs = true;
      enableWidevine = true;
      commandLineArgs = "--enable-features=WebUIDarkMode --force-dark-mode";
    })

    # plex-media-player # Plex Player (shitty TV version)
    prismlauncher # Minecraft launcher
    remmina # Remote desktop client
    libreoffice-fresh
    # via # Keyboard Configurator
  ];

  programs.java = {
    enable = true;
    package = pkgs.jdk17;
  };

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
    ];
  };
}
