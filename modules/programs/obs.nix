_: {
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
        obs-backgroundremoval # Remove background from camera
      ];
    };
  };
}
