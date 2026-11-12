{
  flake.modules.nixos.desktop = {pkgs, ...}: {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
      # jack.enable = true; # `services.pipewire.jack.enable` is deprecated, because it introduces global impurity via `LD_LIBRARY_PATH`. Use the `pw-jack` wrapper from `pipewire.jack` where necessary instead.
    };
  };
}
