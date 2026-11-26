{config, ...}: let
  username = config.flake.meta.user.username;
in {
  # Podman as a drop-in Docker replacement. Mutually exclusive with
  # "virtualization/docker": only one can serve /run/docker.sock (upstream
  # assertion).
  flake.modules.nixos."virtualization/podman" = {pkgs, ...}: {
    virtualisation.podman = {
      # /run/docker.sock speaks the Docker API; docker tools talk to it
      # unmodified. The podman group is root-equivalent, like docker's.
      enable = true;
      dockerSocket.enable = true;
      dockerCompat = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
      # aardvark-dns: compose projects get service-name DNS like Docker's
      # embedded DNS.
      defaultNetwork.settings.dns_enabled = true;
    };

    # Docker's exact default capability set — podman omits NET_RAW, breaking
    # raw sockets (ping, ICMP healthchecks).
    virtualisation.containers.containersConf.settings.containers.default_capabilities = [
      "CHOWN"
      "DAC_OVERRIDE"
      "FOWNER"
      "FSETID"
      "KILL"
      "MKNOD"
      "NET_BIND_SERVICE"
      "NET_RAW"
      "SETFCAP"
      "SETGID"
      "SETPCAP"
      "SETUID"
      "SYS_CHROOT"
    ];

    users.users.${config.flake.meta.user.username}.extraGroups = ["podman"];

    # Docker API client; drives the podman-backed /run/docker.sock unchanged.
    environment.systemPackages = with pkgs; [
      docker-compose
    ];

    networking.firewall.trustedInterfaces = ["podman0"];
  };

  # Home Manager: docker-compatible tooling at XDG locations.
  flake.modules.homeManager."virtualization/podman" = {config, ...}: {
    home.sessionVariables = {
      # config.json: compose CLI config and `podman login` credentials.
      DOCKER_CONFIG = "${config.xdg.configHome}/docker";
      # Steer docker tooling to the root socket: podman's `docker compose`
      # alias otherwise routes to the rootless socket, where docker-compose's
      # hardcoded oom_score_adj 0 fails under the user manager's OOM floor
      # (containers/crun#2466, fixed upstream in 5a5bcb8, not in our pin).
      # Rootless use: override per-command, or set oom_score_adj: 200.
      DOCKER_HOST = "unix:///run/docker.sock";
    };
  };

  # Preservation companion for "virtualization/podman" (auto-resolved by the prefix).
  flake.modules.nixos."preservation/virtualization/podman" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath} = {
      directories = [
        # Root podman storage: images, volumes, build cache.
        "/var/lib/containers"
      ];
      users.${username} = {
        directories = [
          # Rootless storage (subuids come free from users-groups).
          ".local/share/containers"
          # containers.conf overrides, auth.json credentials.
          ".config/containers"
          # DOCKER_CONFIG: compose config, podman login credentials.
          ".config/docker"
        ];
      };
    };
  };
}
