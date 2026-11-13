{config, ...}: let
  # Flake-level user metadata; config.flake does not exist inside NixOS
  # modules, which shadow `config` with the host config.
  username = config.flake.meta.user.username;
in {
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

  # Preservation companion for "desktop" (auto-resolved by the prefix).
  flake.modules.nixos."preservation/desktop" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath} = {
      directories = [
        # ALSA mixer levels.
        "/var/lib/alsa"
      ];
      users.${username}.directories = [
        # Remembered device profiles and per-node volume/route state.
        ".local/state/wireplumber"
      ];
    };
  };
}
