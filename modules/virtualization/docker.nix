{config, ...}: {
  flake.modules.nixos."virtualization/docker" = {pkgs, ...}: {
    # Docker
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };

    users.users.${config.flake.meta.user.username}.extraGroups = ["docker"];

    environment.systemPackages = with pkgs; [
      docker-compose
    ];

    networking.firewall.trustedInterfaces = ["docker0"];
  };

  # Home Manager: point docker CLI config at XDG locations.
  # DOCKER_CONFIG holds config.json/contexts (real config);
  # buildx stores build state there by default, so divert it to state home.
  flake.modules.homeManager."virtualization/docker" = {config, ...}: {
    home.sessionVariables = {
      DOCKER_CONFIG = "${config.xdg.configHome}/docker";
      BUILDX_CONFIG = "${config.xdg.stateHome}/docker/buildx";
    };
  };
}
