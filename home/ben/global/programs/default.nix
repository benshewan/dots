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
    # Note: Should replace with thorium when that becomes available
    thorium
    # mercury
    # (vivaldi.override {
    #   proprietaryCodecs = true;
    #   enableWidevine = true;
    #   commandLineArgs = "--enable-features=WebUIDarkMode --force-dark-mode";
    # })

    # plex-media-player # Plex Player (shitty TV version)
    remmina # Remote desktop client
    libreoffice-fresh
    bitwarden
    bottles
    # via # Keyboard Configurator
  ];

  programs.java = {
    enable = true;
    package = pkgs.jdk17;
  };

  programs.git = {
    enable = true;
    userName = "Ben Shewan";
    userEmail = "benbshewan@gmail.com";
    extraConfig = {
      pull.rebase = false;
    };
  };
}
