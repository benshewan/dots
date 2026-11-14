_: {
  # Self-hosted binary cache server (attic) so desktops can share builds.
  # Push-based: clients push over HTTP with a token, the server signs
  # on-the-fly (signing key never leaves apus), NARs are deduplicated and
  # LRU-garbage-collected. SQLite + local storage in monolithic mode is
  # fine at this scale.
  flake.modules.nixos."services/attic" = {config, ...}: {
    sops.secrets."atticd-env" = {
      owner = "root";
      group = "root";
      mode = "0400";
    };

    services.atticd = {
      enable = true;

      # sops secret containing ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64
      # (openssl genrsa -traditional 4096 | base64 -w0). systemd reads the
      # EnvironmentFile itself, so the default root-only sops mode works
      # despite atticd running as a DynamicUser.
      environmentFile = config.sops.secrets."atticd-env".path;

      settings = {
        listen = "[::]:8080";
        jwt = {};

        # Time-based GC bounds disk-fill from upload floods (interval
        # defaults to 12h).
        garbage-collection.default-retention-period = "90 days";

        # TODO(production): set allowed-hosts to the endpoint host:port
        # desktops use; empty allows any Host header.
      };
    };

    # Serve the cache on the LAN
    networking.firewall.allowedTCPPorts = [8080];
    # TODO(hardening): restrict 8080 to the LAN source subnet once the
    # address is known (extraInputCommands), or put nginx + TLS in front —
    # plain HTTP leaks push tokens to LAN sniffing.
    #
    # Systemd-level hardening needs nothing: the nixpkgs atticd unit ships
    # DynamicUser, empty capabilities, syscall filter, ProtectSystem=strict,
    # PrivateDevices/Tmp/Users, ProtectProc=invisible. Token scoping is the
    # remaining lever: create the cache private, and issue per-machine
    # tokens with only push+pull on that cache (atticd-atticadm make-token
    # --validity ...).
  };

  # Preservation companion (auto-attached with "services/attic"): sqlite DB
  # and chunk storage live under /var/lib/atticd, tmpfs on erased-root
  # layouts. systemd's StateDirectory chowns the mount point on start, so
  # the DynamicUser uid drift is fine.
  flake.modules.nixos."preservation/services/attic" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.directories = [
      {
        directory = "/var/lib/atticd";
        user = "atticd";
        group = "atticd";
        mode = "0700";
      }
    ];
  };
}
