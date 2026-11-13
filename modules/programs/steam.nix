{config, ...}: let
  # Flake-level user metadata; config.flake does not exist inside NixOS
  # modules, which shadow `config` with the host config.
  username = config.flake.meta.user.username;
in {
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

  # Preservation companion for "programs/steam" (auto-resolved by the prefix).
  flake.modules.nixos."preservation/programs/steam" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username} = {
      directories = [
        # Game library, Proton prefixes, saves and account data. .steam holds
        # symlinks and the registry pointing into it. The ~/.steampid and
        # ~/.steampath symlinks steam creates at every launch are
        # deliberately NOT preserved: they are runtime pointers (pid file)
        # into .steam and must be stale-free.
      ".local/share/Steam"
      ".steam"
      ];
    };
  };
}
