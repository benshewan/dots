{config, ...}: let
  # Flake-level user metadata; config.flake does not exist inside NixOS
  # modules, which shadow `config` with the host config.
  username = config.flake.meta.user.username;
in {
  flake.modules.homeManager."programs/obs" = {
    pkgs,
    lib,
    ...
  }: {
    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-pipewire-audio-capture # Capture individual application audio
        # obs-backgroundremoval # Remove background from camera
      ];
    };
  };

  # Preservation companion for "programs/obs" (auto-resolved by the prefix).
  flake.modules.nixos."preservation/programs/obs" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username}.directories = [
      # Scene collections, profiles and service credentials.
      ".config/obs-studio"
    ];
  };
}
