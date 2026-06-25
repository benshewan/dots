_: {
  flake.modules.nixos."programs/steam" = {pkgs, ...}: {
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
      # gamescope -w 1280 -h 720 -W 2560 -H 1440 -F fsr -- %command%
      package = pkgs.steam.override {
        extraPkgs = pkgs':
          with pkgs'; [
            libXcursor
            libXi
            libXinerama
            libXScrnSaver
            libpng
            libpulseaudio
            libvorbis
            stdenv.cc.cc.lib # Provides libstdc++.so.6
            libkrb5
            keyutils
            # Add other libraries as needed
          ];
      };
    };

    programs.gamescope = {
      enable = true;
    };
  };
}
