{config, ...}: let
  username = config.flake.meta.user.username;
in {
  flake.modules.homeManager."programs/audio-relay" = {pkgs, ...}: {
    home.packages = with pkgs; [
      local.audiorelay
    ];
  };

  # The virtual-mic pipewire graph only works at the NixOS level
  # (services.pipewire.extraConfig doesn't exist in HM — its configPackages
  # equivalent turned out unnecessary). Kept as its own NixOS module in
  # this file so it attaches wherever "programs/audio-relay" is resolved.
  flake.modules.nixos."programs/audio-relay" = {
    # 59100 TCP+UDP: control channel / audio streaming; 59200 UDP: audio
    # stream. Both hosts use these defaults.
    networking.firewall.allowedTCPPorts = [59100];
    networking.firewall.allowedUDPPorts = [59100 59200];

    services.pipewire.extraConfig.pipewire = {
      "10-null-sink" = {
        "context.objects" = [
          {
            factory = "adapter";
            args = {
              "factory.name" = "support.null-audio-sink";
              "node.name" = "audiorelay-virtual-mic-sink";
              "node.description" = "Virtual Mic Sink";
              "media.class" = "Audio/Sink";
              "audio.position" = "FL,FR";
            };
          }
        ];
      };
      "20-virtual-mic" = {
        "context.modules" = [
          {
            name = "libpipewire-module-loopback";
            args = {
              "capture.props" = {
                "node.target" = "audiorelay-virtual-mic-sink";
              };
              "playback.props" = {
                "node.name" = "audiorelay-virtual-mic";
                "node.description" = "Virtual Mic";
                "media.class" = "Audio/Source";
                "audio.position" = "FL,FR";
                "node.passive" = true;
              };
            };
          }
        ];
      };
    };
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
