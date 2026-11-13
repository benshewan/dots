{config, ...}: let
  username = config.flake.meta.user.username;
in {
  flake.modules.homeManager."programs/audio-relay" = {pkgs, ...}: {
    home.packages = with pkgs; [
      local.audiorelay
    ];

    # HM services.pipewire has no extraConfig; the equivalent is a
    # configPackages drop-in for share/pipewire/pipewire.conf.d/
    # (NixOS: services.pipewire.extraConfig.pipewire).
    services.pipewire.configPackages = [
      (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/10-audiorelay-virtual-mic.conf" ''
        context.objects = [
          {
            factory = adapter
            args = {
              factory.name = support.null-audio-sink
              node.name = audiorelay-virtual-mic-sink
              node.description = "Virtual Mic Sink"
              media.class = Audio/Sink
              audio.position = "FL,FR"
            }
          }
        ]
        context.modules = [
          {
            name = libpipewire-module-loopback
            args = {
              capture.props = {
                node.target = audiorelay-virtual-mic-sink
              }
              playback.props = {
                node.name = audiorelay-virtual-mic
                node.description = "Virtual Mic"
                media.class = Audio/Source
                audio.position = "FL,FR"
                node.passive = true
              }
            }
          }
        ]
      '')
    ];
  };

  # Preservation companion for "programs/audio-relay" (auto-resolved by the
  # prefix).
  # Settings live in Java Preferences (java.util.prefs userRoot →
  # ~/.java/.userPrefs/com/azefsw) which is SHARED across all Java apps
  # using the standard Preferences API — preserved with the granular home
  # essentials instead. Deliberately NOT preserved:
  # - .local/share/audiorelay — only single-instance lock files (runtime).
  # - .skiko — Compose/Skiko native library cache (regenerated).
  # - .config/pulse/cookie — cross-app libpulse auth cookie, in the
  #   essentials too.
  flake.modules.nixos."preservation/programs/audio-relay" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.users.${username} = {};
  };
}
