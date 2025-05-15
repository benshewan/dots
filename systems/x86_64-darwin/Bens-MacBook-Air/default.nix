{pkgs, ...}: {
  night-sky = {
    home.extraOptions.night-sky = {
      programs = {
        vscode.enable = true;
        # firefox.enable = true;
        # chromium.enable = true;
        # mongodb-compass.enable = true;
        # kitty.enable = true;
        spotify.enable = true;
        webstorm.enable = true;
        fish.enable = true;
        # kdeconnect.enable = true;
      };
    };
  };

  services.tailscale.enable = true;
  homebrew.casks = [
    "scroll-reverser" # fix stupid natural scrolling
    "alfred" # Spotlight replacement
    "orion" # webkit based browser with tree style tabs
    "mongodb-compass" # Database browser
  ];

  environment.systemPackages = with pkgs;
    [
      python3
    ]
    # Development stuff
    ++ (with pkgs; [
      nodejs
    ]);
}
